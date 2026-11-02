# player

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
## Linux development

Install the development packages `libgstreamer1.0-dev`,
`libgstreamer-plugins-base1.0-dev`, and `libsqlite3-dev`, then run `flutter pub get` and
`flutter run -d linux`. Linux currently starts without Firebase or automatic
music-library discovery; `on_audio_query` does not support Linux.

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
