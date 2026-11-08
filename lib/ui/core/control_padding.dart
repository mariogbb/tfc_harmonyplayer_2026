import 'package:flutter/material.dart';
import 'package:player/control/media_control.dart';
import 'package:provider/provider.dart';
import 'package:player/ui/core/desktop_content_scope.dart';

class ControlPadding extends StatelessWidget {
  final Widget child;

  const ControlPadding({
    Key? key,
    required this.child,
    this.playerFraction = 0.1,
  }) : super(key: key);
  final double playerFraction;

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding:
          (!DesktopContentScope.isActive(context) &&
              context.watch<PlayerHandler>().playingSong != null)
          ? EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * playerFraction,
            )
          : EdgeInsets.zero,
      duration: const Duration(milliseconds: 500),
      child: child,
    );
  }
}
