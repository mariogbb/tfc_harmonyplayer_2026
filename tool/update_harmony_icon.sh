#!/usr/bin/env bash
# Rebuild the app and launcher icons from the editable SVG.
# Requires ffmpeg with librsvg, Python Pillow, and Flutter dependencies.
set -euo pipefail
cd "$(dirname "$0")/.."

ffmpeg -hide_banner -loglevel error -y -c:v librsvg -width 1024 -height 1024 \
  -i assets/branding/harmony.svg -frames:v 1 -update 1 assets/harmony_mark.png
dart run flutter_launcher_icons
python3 - <<'PY'
from PIL import Image

image = Image.open('assets/harmony_mark.png').convert('RGBA')
image.save('windows/runner/resources/app_icon.ico', format='ICO',
           sizes=[(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
PY
