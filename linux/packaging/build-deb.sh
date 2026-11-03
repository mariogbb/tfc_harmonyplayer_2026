#!/usr/bin/env bash
set -euo pipefail

# Build on the oldest Ubuntu/Debian release you intend to support: binary
# dependencies are derived from the libraries present on the build machine.
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root"

for command in flutter dpkg-deb dpkg-shlibdeps dpkg-architecture python3; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "Missing required build tool: $command" >&2
    exit 1
  fi
done

architecture="$(dpkg-architecture -qDEB_HOST_ARCH)"
multiarch="$(dpkg-architecture -qDEB_HOST_MULTIARCH)"
case "$architecture" in
  amd64) flutter_arch=x64 ;;
  arm64) flutter_arch=arm64 ;;
  *) echo "Unsupported Flutter Linux architecture: $architecture" >&2; exit 1 ;;
esac

version="$(python3 -c 'import re; from pathlib import Path; text = Path("pubspec.yaml").read_text(); match = re.search(r"(?m)^version:\s*[\x27\x22]?([0-9]+\.[0-9]+\.[0-9]+)(?:\+[0-9]+)?[\x27\x22]?\s*$", text); print(match.group(1) if match else "")')"
if [[ -z "$version" ]]; then
  echo 'Could not read a supported version from pubspec.yaml.' >&2
  exit 1
fi

flutter build linux --release
bundle="$root/build/linux/$flutter_arch/release/bundle"
if [[ ! -x "$bundle/player" ]]; then
  echo "Release bundle not found at $bundle" >&2
  exit 1
fi

work="$(mktemp -d "${TMPDIR:-/tmp}/harmony-player-deb.XXXXXXXX")"
trap 'rm -rf -- "$work"' EXIT
stage="$work/package"
install -d "$stage/DEBIAN" "$stage/usr/lib/harmony-player" \
  "$stage/usr/bin" "$stage/usr/share/applications" \
  "$stage/usr/share/pixmaps" "$work/debian"
cp -a "$bundle/." "$stage/usr/lib/harmony-player/"
# sqlite3's current native-asset manifest requests libsqlite3.so, while the
# runtime package ships libsqlite3.so.0. Keep the compatibility link private.
ln -s "/usr/lib/$multiarch/libsqlite3.so.0" "$stage/usr/lib/harmony-player/lib/libsqlite3.so"
install -m 644 linux/packaging/harmony-player.desktop "$stage/usr/share/applications/"
install -m 644 assets/app_icon.png "$stage/usr/share/pixmaps/harmony-player.png"
cat > "$stage/usr/bin/harmony-player" <<'EOF'
#!/bin/sh
export LD_LIBRARY_PATH="/usr/lib/harmony-player/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
exec /usr/lib/harmony-player/player "$@"
EOF
chmod 755 "$stage/usr/bin/harmony-player"

# dpkg-shlibdeps reads source metadata, even though this is a binary package.
cat > "$work/debian/control" <<'EOF'
Source: harmony-player
Section: sound
Priority: optional
Maintainer: Harmony Player maintainers <noreply@localhost>

Package: harmony-player
Architecture: any
Description: Local music player
EOF

binary_args=(-e"$stage/usr/lib/harmony-player/player")
for library in "$stage/usr/lib/harmony-player/lib/"*.so; do
  [[ -L "$library" ]] && continue
  binary_args+=(-e"$library")
done
native_dependencies="$(cd "$work" && dpkg-shlibdeps -O -S"$stage" -l"$stage/usr/lib/harmony-player/lib" "${binary_args[@]}")"
native_dependencies="${native_dependencies#shlibs:Depends=}"
if [[ -z "$native_dependencies" || "$native_dependencies" == shlibs:* ]]; then
  echo 'Failed to determine native library dependencies.' >&2
  exit 1
fi

cat > "$stage/DEBIAN/control" <<EOF
Package: harmony-player
Version: $version
Section: sound
Priority: optional
Architecture: $architecture
Maintainer: Harmony Player maintainers <noreply@localhost>
Depends: $native_dependencies, gstreamer1.0-plugins-base, gstreamer1.0-plugins-good, gstreamer1.0-alsa, gstreamer1.0-libav, libsqlite3-0, ffmpeg
Recommends: xdg-user-dirs
Description: Music player for local libraries
 Harmony Player scans a local music directory and plays audio files.
EOF

output="$root/build/harmony-player_${version}_${architecture}.deb"
dpkg-deb --build --root-owner-group "$stage" "$output"
echo "Package created: $output"
