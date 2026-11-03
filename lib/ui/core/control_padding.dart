import 'package:flutter/material.dart';
import 'package:player/control/media_control.dart';
import 'package:provider/provider.dart';

class ControlPadding extends StatelessWidget {
  final Widget child;

  const ControlPadding({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: (context.watch<PlayerHandler>().playingSong != null)
          ? EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.1)
          : EdgeInsets.zero,
      duration: const Duration(milliseconds: 500),
      child: child,
    );
  }
}
