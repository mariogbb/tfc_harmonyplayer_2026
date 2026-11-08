import 'package:flutter/material.dart';
import 'package:player/theme_data/neo_style.dart';

class AppTabBar extends TabBar {
  const AppTabBar({super.key, required super.tabs, required super.controller});

  @override
  Size get preferredSize => Size.fromHeight(super.preferredSize.height + 18);

  @override
  State<AppTabBar> createState() => AppTabBarState();
}

class AppTabBarState extends State<AppTabBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: NeoStyle.surface(context),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: DecoratedBox(
        decoration: NeoStyle.raised(context, radius: 20),
        child: TabBar(
          tabs: widget.tabs,
          controller: widget.controller,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: NeoStyle.control(context, radius: 15, selected: true),
          indicatorPadding: const EdgeInsets.all(5),
          dividerColor: Colors.transparent,
          splashBorderRadius: BorderRadius.circular(15),
          labelColor: theme.primaryColor,
          unselectedLabelColor: theme.colorScheme.onSurface.withValues(
            alpha: 0.7,
          ),
        ),
      ),
    );
  }
}
