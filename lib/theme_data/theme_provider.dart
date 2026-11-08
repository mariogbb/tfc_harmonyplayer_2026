import 'package:flutter/material.dart';

import 'dart:developer' as developer;

import 'package:player/theme_data/top_bar_theme.dart';
import 'package:player/theme_data/neo_style.dart';
import 'package:player/utils/extensions.dart';
import 'package:player/data/services/settings/settings_store.dart';

class ThemeProvider with ChangeNotifier {
  ThemeProvider(SettingsStore store)
    : selectedThemeMode = recoverThemeMode(store),
      selectedPrimaryColor = recoverColor(store),
      selectedTopBarTheme = recoverTopBarTheme(store);

  ThemeMode selectedThemeMode;
  Color selectedPrimaryColor;
  TopBarTheme selectedTopBarTheme;

  static TextStyle appBarText = const TextStyle(
    color: Colors.white70,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static TopBarTheme recoverTopBarTheme(SettingsStore store) {
    TopBarTheme out = TopBarTheme.seamless;

    int? index = store.read<int>(
      "topbar_theme",
      defaultValue: TopBarTheme.values.indexOf(TopBarTheme.seamless),
    );

    if (index != null && index >= 0 && index < TopBarTheme.values.length) {
      out = TopBarTheme.values[index];
    }

    return out;
  }

  static Color recoverColor(SettingsStore store) {
    Color c = NeoStyle.defaultAccent;

    String? color = store.read<String>("accent_color");

    if (color != null) {
      try {
        c = color.toColor();
      } on FormatException catch (error, stack) {
        developer.log(
          'Invalid saved accent color; using the default.',
          name: 'settings',
          error: error,
          stackTrace: stack,
        );
      }
    }

    return c;
  }

  static ThemeMode recoverThemeMode(SettingsStore store) {
    ThemeMode mode = ThemeMode.system;

    int? index = store.read<int>("color_mode");

    if (index != null && index >= 0 && index < ThemeMode.values.length) {
      mode = ThemeMode.values[index];
    }

    return mode;
  }

  AppBarTheme getAppBarTheme() {
    return getSelectedAppBarTheme(selectedTopBarTheme, selectedPrimaryColor);
  }

  static MaterialColor getMaterialColorFromColor(Color color) {
    Map<int, Color> colorShades = {
      50: getShade(color, value: 0.5),
      100: getShade(color, value: 0.4),
      200: getShade(color, value: 0.3),
      300: getShade(color, value: 0.2),
      400: getShade(color, value: 0.1),
      500: color,
      600: getShade(color, value: 0.1, darker: true),
      700: getShade(color, value: 0.15, darker: true),
      800: getShade(color, value: 0.2, darker: true),
      900: getShade(color, value: 0.25, darker: true),
    };
    return MaterialColor(color.toARGB32(), colorShades);
  }

  static Color getShade(Color color, {bool darker = false, double value = .1}) {
    assert(value >= 0 && value <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness(
      (darker ? (hsl.lightness - value) : (hsl.lightness + value)).clamp(
        0.0,
        1.0,
      ),
    );

    return hslDark.toColor();
  }

  void setSelectedThemeMode(ThemeMode themeMode) {
    selectedThemeMode = themeMode;
    notifyListeners();
  }

  void setSelectedPrimaryColor(Color color) {
    selectedPrimaryColor = color;

    notifyListeners();
  }

  void setSelectedTopBarTheme(TopBarTheme theme) {
    selectedTopBarTheme = theme;

    notifyListeners();
  }
}
