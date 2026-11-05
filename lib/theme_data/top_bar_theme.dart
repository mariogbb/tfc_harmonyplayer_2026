import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:player/theme_data/dark_theme.dart';
import 'package:player/theme_data/light_theme.dart';

enum TopBarTheme { rounded, squared, seamless }

AppBarTheme getSelectedAppBarTheme(TopBarTheme theme, Color primaryColor) {
  return (SchedulerBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark)
      ? DarkTheme.getAppBarTheme(theme, primaryColor)
      : LightTheme.getAppBarTheme(theme, primaryColor);
}
