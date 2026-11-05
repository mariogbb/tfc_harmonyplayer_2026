# Harmony Player

A Flutter music player for local libraries. Android is the original target;
Linux and Windows have desktop implementations that still need full implementation of
the media player calls.

## Development checks

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib/app lib/control lib/data/dao.dart lib/data/repositories lib/data/services lib/ui lib/main.dart test integration_test
flutter analyze
flutter test
```

On Linux with a graphical session and working GStreamer plugins, run the native
discovery, SQLite and playback smoke test with:

```sh
flutter test integration_test/desktop_smoke_test.dart -d linux
```

With an Android device or emulator connected, run the sandbox playback and
playlist persistence smoke test with:

```sh
flutter test integration_test/android_smoke_test.dart -d <device-id>
```

Media-library permissions and background playback still need manual device checks.

## Linux development

Install the development packages `libgstreamer1.0-dev`,
`libgstreamer-plugins-base1.0-dev`, and `libsqlite3-dev`, plus GStreamer playback
plugins for your music formats. Run `flutter pub get` and `flutter run -d linux`.
The library scans the XDG Music directory (or `~/Music`); install `ffmpeg` to
make `ffprobe` available for metadata and duration detection. Without it, files
are listed using their filenames and have unknown durations. Firebase and system
media integration are not initialized on Linux, and desktop artwork currently
uses a placeholder.

### Debian/Ubuntu package

On Debian/Ubuntu, build the package on the oldest distribution release you plan
to support (the generated binary dependencies reflect the build machine):

```sh
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libsqlite3-dev dpkg-dev
flutter pub get
linux/packaging/build-deb.sh
```

This creates `build/harmony-player_<version>_<architecture>.deb`. Install it
using `apt` rather than `dpkg -i`, so runtime dependencies are resolved:

```sh
sudo apt install ./build/harmony-player_<version>_<architecture>.deb
```

## Windows development

On Windows, install the Flutter Windows desktop prerequisites and run
`flutter pub get` followed by `flutter run -d windows`. The library scans
`%USERPROFILE%\Music`; `ffprobe` on PATH is optional but needed for metadata
and duration detection. SQLite's native DLL must be available to
`sqflite_common_ffi`. Firebase, system media integration, and embedded artwork
are not currently enabled on desktop. Windows builds and playback should be
verified on a Windows machine.

On Windows, the native discovery, SQLite and playback smoke test can be run with
`flutter test integration_test/desktop_smoke_test.dart -d windows` after
installing the Flutter Windows desktop prerequisites and an audio output device.

## Local Firebase setup

Firebase configuration is intentionally not included. Install the Firebase CLI
and FlutterFire CLI, select your own Firebase project, and run
`flutterfire configure` from this directory to generate `lib/firebase_options.dart`
and the platform configuration files. These local files are ignored by Git.
On Android and Apple platforms, the native configuration files are required to
initialize Firebase. Linux development does not require Firebase configuration.
Register the Android and Apple apps with the identifier
`dev.mariobesada.player` when configuring Firebase.

Do not add secrets to Flutter assets or `--dart-define`: values bundled into a
client application can be extracted. Keep privileged credentials on a server.
