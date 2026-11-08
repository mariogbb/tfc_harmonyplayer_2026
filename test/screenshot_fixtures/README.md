# Product screenshot fixtures

The widget-test fixture renders the real dashboard, album list, and song list
with example song metadata. It uses generated abstract covers, an in-memory
library, fake settings and a fake playback backend. The paths are deliberately
nonexistent: no MP3 files, real library, network artwork, or user database are
read or modified. These are isolated content screenshots, not the complete
desktop shell or mobile application.

Generate desktop (1200 × 900) and mobile (390 × 844) PNGs in both themes with:

```sh
flutter test --no-pub \
  --dart-define=SCREENSHOT_DIR=docs/screenshots \
  test/screenshot_fixtures/product_screenshots_test.dart
```

The command writes (and overwrites) files named
`<desktop|mobile>-<light|dark>-<dashboard|albums|songs>.png` in the selected
directory. Without `SCREENSHOT_DIR`, the test
checks the fixture but does not write images. Covers are original abstract
graphics, not the albums' official artwork; review rights and branding before
publishing names or screenshots commercially.

## Full shell with Deezer artwork

The alternative fixture renders the real `HomePage` shell with the same
in-memory sample songs and a fake audio backend. The images are retrieved from
Deezer first and used as local fixture artwork; this does not exercise the app's
live network artwork loading. It writes twelve screenshots under
`docs/screenshots/deezer/`:

```sh
python3 tool/fetch_screenshot_covers.py /tmp/opencode/harmony-deezer
flutter test --no-pub \
  --dart-define=DEEZER_COVER_DIR=/tmp/opencode/harmony-deezer \
  --dart-define=SCREENSHOT_DIR=docs/screenshots/deezer \
  test/screenshot_fixtures/deezer_app_screenshots_test.dart
```

The download script overwrites numbered JPEGs in its output directory and
prints their source URLs. Results can change as Deezer's search results change.
The artwork and resulting screenshots contain third-party copyrighted material;
check permissions and applicable terms before publishing or redistributing.
