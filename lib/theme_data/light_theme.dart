import 'package:flutter/material.dart';
import 'package:player/theme_data/theme_provider.dart';
import 'package:player/theme_data/top_bar_theme.dart';

class LightTheme {
  static ThemeData getTheme(Color primaryColor, TopBarTheme topBarTheme) {
    return ThemeData(
      primarySwatch: ThemeProvider.getMaterialColorFromColor(primaryColor),
      primaryColor: primaryColor,
      brightness: Brightness.light,
      highlightColor: Colors.white70,
      tabBarTheme: TabBarThemeData(
        unselectedLabelColor: Colors.grey,
        labelColor: primaryColor,
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      appBarTheme: getAppBarTheme(topBarTheme, primaryColor),
    );
  }

  static AppBarTheme getAppBarTheme(TopBarTheme theme, Color primaryColor) {
    TextStyle appBarText = const TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    );

    switch (theme) {
      case TopBarTheme.rounded:
        return AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          titleTextStyle: appBarText,
          iconTheme: IconThemeData(color: primaryColor),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: primaryColor, width: 2),
            borderRadius: BorderRadius.circular(25),
          ),
        );
      case TopBarTheme.squared:
        return const AppBarTheme(
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        );
      case TopBarTheme.seamless:
        return AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.white,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: appBarText,
        );
    }
  }
}
