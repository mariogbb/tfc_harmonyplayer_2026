import 'package:flutter/material.dart';
import 'package:player/theme_data/neo_style.dart';
import 'package:player/ui/core/desktop_content_scope.dart';

class AdaptiveSettingsScreen extends StatelessWidget {
  const AdaptiveSettingsScreen({
    super.key,
    required this.title,
    required this.children,
  });
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: DesktopContentScope.isActive(context)
        ? null
        : AppBar(title: Text(title)),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 24),
          children: children,
        ),
      ),
    ),
  );
}

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
    child: Container(
      decoration: NeoStyle.raised(context, radius: 22),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            ...children,
          ],
        ),
      ),
    ),
  );
}
