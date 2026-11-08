import 'package:flutter_test/flutter_test.dart';
import 'package:player/data/services/settings/settings_store.dart';
import 'package:player/data/settings.dart';
import 'package:player/theme_data/theme_provider.dart';
import 'package:player/theme_data/top_bar_theme.dart';
import 'package:flutter/material.dart';

class FakeSettingsStore implements SettingsStore {
  final values = <String, Object>{};
  bool failWrites = false;
  @override
  T? read<T>(String key, {T? defaultValue}) =>
      values[key] as T? ?? defaultValue;
  @override
  Future<void> write<T>(String key, T value) async {
    if (failWrites) throw StateError('storage error');
    values[key] = value as Object;
  }
}

void main() {
  test('restores and persists settings without a global singleton', () async {
    final store = FakeSettingsStore()..values['show_tab_label'] = false;
    final settings = PlayerSettings(store);
    addTearDown(settings.dispose);
    expect(settings.isShowTabLabel, isFalse);
    settings.setUserName('Listener');
    settings.setFilterDuration(12);
    settings.showTabLabels(true);
    settings.setLocale(const Locale('es'));
    expect(store.values['user_name'], 'Listener');
    expect(store.values['filterDuration'], 12.0);
    final restored = PlayerSettings(store);
    addTearDown(restored.dispose);
    expect(restored.getUserName, 'Listener');
    expect(restored.getAppLocale?.languageCode, 'es');
  });

  test('theme handles out-of-range persisted options safely', () {
    final store = FakeSettingsStore()
      ..values['color_mode'] = 99
      ..values['topbar_theme'] = -1
      ..values['accent_color'] = 'invalid';
    final theme = ThemeProvider(store);
    addTearDown(theme.dispose);
    expect(theme.selectedThemeMode, ThemeMode.system);
    expect(theme.selectedTopBarTheme, TopBarTheme.seamless);
    expect(theme.selectedPrimaryColor, const Color(0xff365cb9));
  });

  test('reports settings write failures and flush waits for writes', () async {
    final store = FakeSettingsStore()..failWrites = true;
    final settings = PlayerSettings(store);
    addTearDown(settings.dispose);
    final oldHandler = FlutterError.onError;
    FlutterError.onError = (_) {};
    addTearDown(() => FlutterError.onError = oldHandler);
    settings.setUserName('Listener');
    await settings.flush();
    expect(settings.lastError, isA<StateError>());
  });
}
