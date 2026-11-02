import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:player/theme_data/dark_theme.dart';
import 'package:player/theme_data/light_theme.dart';

enum TopBarTheme { rounded, squared, seamless }

AppBarTheme getSelectedAppBarTheme(TopBarTheme theme) {
  return (SchedulerBinding.instance.window.platformBrightness ==
          Brightness.dark)
      ? DarkTheme.getAppBarTheme(theme)
      : LightTheme.getAppBarTheme(theme);
}
