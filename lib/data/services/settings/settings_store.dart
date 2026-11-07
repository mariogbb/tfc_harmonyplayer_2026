import 'package:flutter_settings_screens/flutter_settings_screens.dart';

abstract class SettingsStore {
  T? read<T>(String key, {T? defaultValue});
  Future<void> write<T>(String key, T value);
}

class FlutterSettingsStore implements SettingsStore {
  @override
  T? read<T>(String key, {T? defaultValue}) =>
      Settings.getValue<T>(key, defaultValue: defaultValue);
  @override
  Future<void> write<T>(String key, T value) =>
      Settings.setValue<T>(key, value);
}
