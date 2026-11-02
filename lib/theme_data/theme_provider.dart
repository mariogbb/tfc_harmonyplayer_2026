import 'package:flutter/material.dart';
import 'package:player/theme_data/top_bar_theme.dart';
import 'package:player/utils/extensions.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode selectedThemeMode = recoverThemeMode();
  Color selectedPrimaryColor = recoverColor();
  TopBarTheme selectedTopBarTheme = recoverTopBarTheme();

  static TextStyle appBarText = const TextStyle(
    color: Colors.white70,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static TopBarTheme recoverTopBarTheme() {
    TopBarTheme out = TopBarTheme.seamless;

    int? index = Settings.getValue<int>("topbar_theme",
        defaultValue: TopBarTheme.values.indexOf(TopBarTheme.seamless));

    if (index != null) {
      out = TopBarTheme.values[index];
    }

    return out;
  }

  static Color recoverColor() {
    Color c = Colors.deepPurple;

    String? color = Settings.getValue<String>("accent_color");

    if (color != null) {
      c = color.toColor();
    }

    return c;
  }

  static ThemeMode recoverThemeMode() {
    ThemeMode mode = ThemeMode.system;

    int? index = Settings.getValue<int>("color_mode");

    if (index != null) {
      mode = ThemeMode.values[index];
    }

    return mode;
  }

  AppBarTheme getAppBarTheme() {
    return getSelectedAppBarTheme(recoverTopBarTheme());
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
    return MaterialColor(color.value, colorShades);
  }

  static Color getShade(Color color, {bool darker = false, double value = .1}) {
    assert(value >= 0 && value <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness(
        (darker ? (hsl.lightness - value) : (hsl.lightness + value))
            .clamp(0.0, 1.0));

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
