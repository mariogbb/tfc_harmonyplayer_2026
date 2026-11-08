import 'package:flutter/material.dart';
import 'package:player/theme_data/neo_style.dart';
import 'package:player/theme_data/top_bar_theme.dart';

class DarkTheme {
  static const Color _backgroundColor = NeoStyle.darkSurface;

  static ThemeData getTheme(Color primaryColor, TopBarTheme topBarTheme) {
    if (primaryColor == NeoStyle.defaultAccent) {
      primaryColor = NeoStyle.darkDefaultAccent;
    }
    return NeoStyle.theme(
      brightness: Brightness.dark,
      accent: primaryColor,
      appBarTheme: getAppBarTheme(topBarTheme, primaryColor),
    );
  }

  static AppBarTheme getAppBarTheme(TopBarTheme theme, Color primaryColor) {
    TextStyle appBarText = const TextStyle(
      color: Color(0xffe6edf6),
      fontSize: 20,
      fontWeight: FontWeight.w700,
    );

    switch (theme) {
      case TopBarTheme.rounded:
        return AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: _backgroundColor,
          titleTextStyle: appBarText,
          iconTheme: IconThemeData(color: primaryColor),
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Color(0xff3c4757)),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        );
      case TopBarTheme.squared:
        return AppBarTheme(
          centerTitle: true,
          backgroundColor: _backgroundColor,
          elevation: 0,
          titleTextStyle: appBarText,
          iconTheme: const IconThemeData(color: Color(0xffe6edf6)),
          shape: const Border(bottom: BorderSide(color: Color(0xff3c4757))),
        );
      case TopBarTheme.seamless:
        return AppBarTheme(
          elevation: 0,
          shadowColor: _backgroundColor,
          backgroundColor: _backgroundColor,
          centerTitle: true,
          titleTextStyle: appBarText,
          iconTheme: const IconThemeData(color: Color(0xffe6edf6)),
        );
    }
  }
}
