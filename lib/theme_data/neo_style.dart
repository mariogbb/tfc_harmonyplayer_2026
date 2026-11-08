import 'package:flutter/material.dart';

/// Surface and shadow palette adapted from mariobesada.dev.
class NeoStyle {
  static const lightSurface = Color(0xffe8edf3);
  static const darkSurface = Color(0xff242b35);
  static const defaultAccent = Color(0xff365cb9);
  static const darkDefaultAccent = Color(0xff98b6ff);

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkSurface
      : lightSurface;

  static BoxDecoration raised(BuildContext context, {double radius = 24}) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: surface(context),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: dark ? const Color(0xff181e26) : const Color(0xffcad3de),
          offset: const Offset(6, 6),
          blurRadius: 16,
        ),
        BoxShadow(
          color: dark ? const Color(0xff303946) : Colors.white,
          offset: const Offset(-6, -6),
          blurRadius: 16,
        ),
      ],
    );
  }

  /// Compact relief for controls and list entries, with a recessed selected state.
  static BoxDecoration control(
    BuildContext context, {
    double radius = 14,
    bool selected = false,
  }) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final shade = dark ? const Color(0xff181e26) : const Color(0xffbdc7d3);
    final highlight = dark ? const Color(0xff36404e) : Colors.white;
    return BoxDecoration(
      color: selected
          ? Color.alphaBlend(
              theme.primaryColor.withValues(alpha: 0.12),
              surface(context),
            )
          : surface(context),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: selected
            ? theme.primaryColor.withValues(alpha: 0.55)
            : theme.dividerColor.withValues(alpha: 0.35),
      ),
      boxShadow: selected
          ? [
              BoxShadow(
                color: shade.withValues(alpha: 0.75),
                offset: const Offset(2, 2),
                blurRadius: 5,
                blurStyle: BlurStyle.inner,
              ),
              BoxShadow(
                color: highlight.withValues(alpha: 0.7),
                offset: const Offset(-2, -2),
                blurRadius: 5,
                blurStyle: BlurStyle.inner,
              ),
            ]
          : [
              BoxShadow(
                color: shade.withValues(alpha: 0.75),
                offset: const Offset(3, 3),
                blurRadius: 7,
              ),
              BoxShadow(
                color: highlight.withValues(alpha: 0.75),
                offset: const Offset(-3, -3),
                blurRadius: 7,
              ),
            ],
    );
  }

  static ThemeData theme({
    required Brightness brightness,
    required Color accent,
    required AppBarTheme appBarTheme,
  }) {
    final dark = brightness == Brightness.dark;
    final surface = dark ? darkSurface : lightSurface;
    final ink = dark ? const Color(0xffe6edf6) : const Color(0xff26364a);
    final secondary = dark ? const Color(0xffb0becf) : const Color(0xff526276);
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
    ).copyWith(primary: accent, surface: surface, onSurface: ink);
    final base = ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      useMaterial3: true,
    );
    return base.copyWith(
      primaryColor: accent,
      scaffoldBackgroundColor: surface,
      canvasColor: surface,
      appBarTheme: appBarTheme,
      textTheme: base.textTheme.apply(bodyColor: ink, displayColor: ink),
      iconTheme: IconThemeData(color: secondary),
      dividerColor: dark ? const Color(0xff3c4757) : const Color(0xffcad3de),
      tabBarTheme: TabBarThemeData(
        labelColor: accent,
        unselectedLabelColor: secondary,
        dividerColor: Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
