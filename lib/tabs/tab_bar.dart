import 'package:flutter/material.dart';
import 'package:player/theme_data/theme_provider.dart';
import 'package:provider/provider.dart';

class AppTabBar extends TabBar {
  AppTabBar({super.key, required super.tabs, required super.controller})
      : super(
          splashBorderRadius: BorderRadius.circular(25),
          indicatorSize: TabBarIndicatorSize.tab,
        );

  @override
  State<AppTabBar> createState() => AppTabBarState();
}

class AppTabBarState extends State<AppTabBar> {
  Widget _darkTab(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).primaryColor.withAlpha(50),
      child: TabBar(
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(45),
          color: Theme.of(context).focusColor,
        ),
        splashBorderRadius: BorderRadius.circular(45),
        indicatorColor: Theme.of(context).primaryColor,
        tabs: super.widget.tabs,
        controller: super.widget.controller,
        unselectedLabelColor: Theme.of(context).unselectedWidgetColor,
      ),
    );
  }

  Widget _lightTab(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).primaryColor.withAlpha(50),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
                color: Theme.of(context).primaryColor.withAlpha(50), width: 2),
          ),
        ),
        child: TabBar(
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(45),
            color: Theme.of(context).focusColor,
          ),
          splashBorderRadius: BorderRadius.circular(45),
          indicatorColor: Theme.of(context).primaryColor,
          tabs: super.widget.tabs,
          controller: super.widget.controller,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, value, child) {
        return (Theme.of(context).brightness == Brightness.dark)
            ? _darkTab(context)
            : _lightTab(context);
      },
    );
  }
}
