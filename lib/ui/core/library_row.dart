import 'package:flutter/material.dart';
import 'package:player/theme_data/neo_style.dart';

/// A quiet, consistent surface for library entries and their actions.
class LibraryRow extends StatelessWidget {
  const LibraryRow({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 5, 16, 7),
      decoration: NeoStyle.control(context, radius: 16),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}
