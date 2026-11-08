import 'package:flutter_test/flutter_test.dart';
import 'package:player/data/services/settings/settings_store.dart';
import 'package:player/data/settings.dart';
import 'package:player/theme_data/theme_provider.dart';
import 'package:player/theme_data/top_bar_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'reads existing settings keys and persists changes without migration',
    () async {
      SharedPreferences.setMockInitialValues({
        'accent_color': '#ff123456',
        'color_mode': 2,
        'topbar_theme': 0,
        'song_artwork_shape': 1,
        'albumtab_artwork_shape': 0,
        'filterDuration': 25.0,
        'smartFilterEnabled': false,
        'show_tab_label': false,
        'show_songs_time_label': true,
        'language': 'es',
      });
      final store = SharedPreferencesSettingsStore(
        await SharedPreferences.getInstance(),
      );
      final settings = PlayerSettings(store);
      final theme = ThemeProvider(store);
      expect(theme.selectedPrimaryColor.toARGB32(), 0xff123456);
      expect(theme.selectedTopBarTheme, TopBarTheme.rounded);
      expect(settings.getFilterDuration, 25);
      expect(settings.isSmartFilterEnabled, isFalse);
      expect(settings.getAppLocale!.languageCode, 'es');
      expect(settings.isShowSongTimeLabel, isTrue);
      expect(store.read<int>('song_artwork_shape'), 1);
      settings.setPreference('color_mode', 1);
      settings.setPreference('song_artwork_shape', 0);
      settings.setFilterDuration(42);
      settings.showTabLabels(true);
      await settings.flush();
      final restored = PlayerSettings(
        SharedPreferencesSettingsStore(await SharedPreferences.getInstance()),
      );
      expect(restored.getFilterDuration, 42);
      expect(restored.isShowTabLabel, isTrue);
      expect(restored.store.read<int>('color_mode'), 1);
      expect(restored.store.read<int>('song_artwork_shape'), 0);
      expect(restored.getAppLocale!.languageCode, 'es');
      restored.dispose();
      settings.dispose();
      theme.dispose();
    },
  );
}
