import 'package:flutter/material.dart';
import 'package:player/theme_data/theme_provider.dart';
import 'package:player/theme_data/top_bar_theme.dart';

class DarkTheme {
  static const Color _backgroundColor = Color.fromRGBO(18, 18, 18, 1);

  static ThemeData getTheme(Color primaryColor) {
    return ThemeData(
      primarySwatch: ThemeProvider.getMaterialColorFromColor(primaryColor),
      primaryColor: primaryColor,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _backgroundColor,
      canvasColor: _backgroundColor,
      highlightColor: primaryColor,
      tabBarTheme: TabBarThemeData(
        unselectedLabelColor: Colors.grey[700],
        labelColor: primaryColor,
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: getAppBarTheme(ThemeProvider.recoverTopBarTheme()),
    );
  }

  static AppBarTheme getAppBarTheme(TopBarTheme theme) {
    TextStyle appBarText = TextStyle(
        color: ThemeProvider.recoverColor(),
        fontSize: 20,
        fontWeight: FontWeight.w700);

    switch (theme) {
      case TopBarTheme.rounded:
        return AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: _backgroundColor,
          titleTextStyle: appBarText,
          iconTheme: IconThemeData(color: ThemeProvider.recoverColor()),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: ThemeProvider.recoverColor(), width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
        );
      case TopBarTheme.squared:
        return AppBarTheme(
          centerTitle: true,
          color: ThemeProvider.recoverColor().withAlpha(50),
          iconTheme: IconThemeData(color: ThemeProvider.recoverColor()),
        );
      case TopBarTheme.seamless:
        return AppBarTheme(
          elevation: 0,
          shadowColor: _backgroundColor.withAlpha(100),
          backgroundColor: _backgroundColor.withAlpha(100),
          centerTitle: true,
        );
    }
  }
}
