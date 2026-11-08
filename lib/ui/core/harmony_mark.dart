import 'package:flutter/material.dart';

/// The shared launcher and in-app brand mark.
class HarmonyMark extends StatelessWidget {
  const HarmonyMark({super.key, this.size = 36});
  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(size * 0.22),
    child: Image.asset(
      'assets/harmony_mark.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
      excludeFromSemantics: true,
    ),
  );
}
