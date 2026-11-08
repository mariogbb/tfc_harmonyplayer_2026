import 'package:flutter/widgets.dart';

/// Marks pages hosted inside the desktop shell, which already owns the player.
class DesktopContentScope extends InheritedWidget {
  const DesktopContentScope({super.key, required super.child});

  static bool isActive(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DesktopContentScope>() != null;

  @override
  bool updateShouldNotify(DesktopContentScope oldWidget) => false;
}
