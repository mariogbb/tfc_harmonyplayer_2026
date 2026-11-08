import 'package:flutter/material.dart';
import 'package:player/theme_data/neo_style.dart';
import 'package:player/theme_data/top_bar_theme.dart';

class LightTheme {
  static ThemeData getTheme(Color primaryColor, TopBarTheme topBarTheme) {
    return NeoStyle.theme(
      brightness: Brightness.light,
      accent: primaryColor,
      appBarTheme: getAppBarTheme(topBarTheme, primaryColor),
    );
  }

  static AppBarTheme getAppBarTheme(TopBarTheme theme, Color primaryColor) {
    TextStyle appBarText = const TextStyle(
      color: Color(0xff26364a),
      fontSize: 20,
      fontWeight: FontWeight.w700,
    );

    switch (theme) {
      case TopBarTheme.rounded:
        return AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: NeoStyle.lightSurface,
          titleTextStyle: appBarText,
          iconTheme: IconThemeData(color: primaryColor),
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Color(0xffcad3de)),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        );
      case TopBarTheme.squared:
        return AppBarTheme(
          centerTitle: true,
          backgroundColor: NeoStyle.lightSurface,
          elevation: 0,
          shape: const Border(bottom: BorderSide(color: Color(0xffcad3de))),
          titleTextStyle: appBarText,
          iconTheme: const IconThemeData(color: Color(0xff26364a)),
        );
      case TopBarTheme.seamless:
        return AppBarTheme(
          backgroundColor: NeoStyle.lightSurface,
          elevation: 0,
          shadowColor: NeoStyle.lightSurface,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xff26364a)),
          titleTextStyle: appBarText,
        );
    }
  }
}
