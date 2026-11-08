import 'package:flutter/material.dart';
import 'package:player/theme_data/neo_style.dart';
import 'package:player/ui/core/harmony_mark.dart';

/// Labeled navigation for wide layouts, with a compact variant for smaller ones.
class DesktopNavigation extends StatelessWidget {
  const DesktopNavigation({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
    required this.expanded,
  });
  final List<Tab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: expanded ? 224 : 76,
      color: NeoStyle.surface(context),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                expanded ? 22 : 0,
                24,
                expanded ? 16 : 0,
                28,
              ),
              child: expanded
                  ? Row(
                      children: [
                        const HarmonyMark(size: 36),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Harmony',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Center(child: HarmonyMark(size: 36)),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                itemCount: tabs.length,
                itemBuilder: (context, index) {
                  final selected = index == selectedIndex;
                  final tab = tabs[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Tooltip(
                      message: expanded ? '' : (tab.text ?? ''),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        decoration: NeoStyle.control(
                          context,
                          selected: selected,
                        ),
                        child: Material(
                          type: MaterialType.transparency,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => onSelected(index),
                            child: Semantics(
                              selected: selected,
                              label: tab.text,
                              child: SizedBox(
                                height: 52,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: expanded ? 56 : 54,
                                      child: IconTheme(
                                        data: IconThemeData(
                                          color: selected
                                              ? theme.primaryColor
                                              : theme.colorScheme.onSurface
                                                    .withValues(alpha: 0.72),
                                        ),
                                        child:
                                            tab.icon ?? const SizedBox.shrink(),
                                      ),
                                    ),
                                    if (expanded)
                                      Expanded(
                                        child: Text(
                                          tab.text ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                                color: selected
                                                    ? theme.primaryColor
                                                    : theme
                                                          .colorScheme
                                                          .onSurface,
                                                fontWeight: selected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
