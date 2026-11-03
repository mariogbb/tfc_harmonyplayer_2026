# Harmony Player

A Flutter music player for local libraries. Android is the original target;
Linux and Windows have desktop implementations that still need full implementation of
the media player calls.

## Development checks

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib/app lib/control/playback_queue.dart lib/data/repositories lib/data/services lib/ui/welcome lib/main.dart test
flutter analyze
flutter test
```

## Linux development

Install the development packages `libgstreamer1.0-dev`,
`libgstreamer-plugins-base1.0-dev`, and `libsqlite3-dev`, plus GStreamer playback
plugins for your music formats. Run `flutter pub get` and `flutter run -d linux`.
The library scans the XDG Music directory (or `~/Music`); install `ffmpeg` to
make `ffprobe` available for metadata and duration detection. Without it, files
are listed using their filenames and have unknown durations. Firebase and system
media integration are not initialized on Linux, and desktop artwork currently
uses a placeholder.

## Windows development

On Windows, install the Flutter Windows desktop prerequisites and run
`flutter pub get` followed by `flutter run -d windows`. The library scans
`%USERPROFILE%\Music`; `ffprobe` on PATH is optional but needed for metadata
and duration detection. SQLite's native DLL must be available to
`sqflite_common_ffi`. Firebase, system media integration, and embedded artwork
are not currently enabled on desktop. Windows builds and playback should be
verified on a Windows machine.

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
