import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsStore {
  T? read<T>(String key, {T? defaultValue});
  Future<void> write<T>(String key, T value);
}

/// Uses the same SharedPreferences keys and value types as the previous UI library.
class SharedPreferencesSettingsStore implements SettingsStore {
  SharedPreferencesSettingsStore(this.preferences);
  final SharedPreferences preferences;
  @override
  T? read<T>(String key, {T? defaultValue}) =>
      preferences.get(key) as T? ?? defaultValue;
  @override
  Future<void> write<T>(String key, T value) async {
    final bool success;
    if (value is bool) {
      success = await preferences.setBool(key, value);
    } else if (value is int) {
      success = await preferences.setInt(key, value);
    } else if (value is double) {
      success = await preferences.setDouble(key, value);
    } else if (value is String) {
      success = await preferences.setString(key, value);
    } else {
      throw ArgumentError.value(value, key, 'Unsupported preference type');
    }
    if (!success) throw StateError('Unable to save preference: $key');
  }
}
