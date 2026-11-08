import 'package:flutter/material.dart';
import 'package:player/data/settings.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/theme_data/theme_provider.dart';
import 'package:player/theme_data/top_bar_theme.dart';
import 'package:player/ui/core/generic_artwork.dart';
import 'package:player/ui/settings/settings_controls.dart';
import 'package:player/ui/settings/settings_section.dart';
import 'package:provider/provider.dart';

class LookAndFeelScreen extends StatelessWidget {
  const LookAndFeelScreen({super.key});

  Future<void> _chooseColor(
    BuildContext context,
    ThemeProvider theme,
    PlayerSettings settings,
  ) async {
    final current = theme.selectedPrimaryColor
        .toARGB32()
        .toRadixString(16)
        .padLeft(8, '0');
    final chosen = await showDialog<Color>(
      context: context,
      builder: (context) => _ColorDialog(initialValue: '#$current'),
    );
    if (chosen == null || !context.mounted) return;
    settings.setPreference(
      'accent_color',
      '#${chosen.toARGB32().toRadixString(16).padLeft(8, '0')}',
    );
    theme.setSelectedPrimaryColor(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context)!;
    final theme = context.watch<ThemeProvider>();
    final settings = context.watch<PlayerSettings>();
    final shapes = <int, String>{
      ArtworkShape.circle.index: labels.song_artwork_shape_circle,
      ArtworkShape.square.index: labels.song_artwork_shape_square,
    };
    final songShape = settings.store.read<int>(
      'song_artwork_shape',
      defaultValue: ArtworkShape.square.index,
    )!;
    final albumShape = settings.store.read<int>(
      'albumtab_artwork_shape',
      defaultValue: ArtworkShape.square.index,
    )!;
    return SafeArea(
      child: AdaptiveSettingsScreen(
        title: labels.look_and_feel,
        children: [
          SettingsSection(
            title: labels.color_scheme,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                title: Text(labels.accent_color),
                trailing: CircleAvatar(
                  backgroundColor: theme.selectedPrimaryColor,
                  child: const Icon(Icons.colorize, color: Colors.white),
                ),
                onTap: () => _chooseColor(context, theme, settings),
              ),
              SettingsChoice<ThemeMode>(
                title: labels.color_mode,
                value: theme.selectedThemeMode,
                options: {
                  ThemeMode.system: labels.color_mode_system,
                  ThemeMode.light: labels.color_mode_ligth,
                  ThemeMode.dark: labels.color_mode_dark,
                },
                onChanged: (mode) {
                  settings.setPreference('color_mode', mode.index);
                  theme.setSelectedThemeMode(mode);
                },
              ),
            ],
          ),
          SettingsSection(
            title: labels.songs_sett,
            children: [
              SettingsChoice<int>(
                title: labels.song_artwork_shape,
                value: songShape,
                options: shapes,
                onChanged: (value) =>
                    settings.setPreference('song_artwork_shape', value),
              ),
              SettingsToggle(
                title: labels.show_song_duration,
                value: settings.isShowSongTimeLabel,
                onChanged: settings.setShowSongTimeLabel,
              ),
            ],
          ),
          SettingsSection(
            title: labels.album_tab_sett,
            children: [
              SettingsChoice<int>(
                title: labels.album_artwork_shape,
                value: albumShape,
                options: {
                  ArtworkShape.circle.index: labels.album_artwork_shape_circle,
                  ArtworkShape.square.index: labels.album_artwork_shape_square,
                },
                onChanged: (value) =>
                    settings.setPreference('albumtab_artwork_shape', value),
              ),
            ],
          ),
          SettingsSection(
            title: labels.app_bar_sett,
            children: [
              SettingsChoice<TopBarTheme>(
                title: labels.app_bar_theme,
                value: theme.selectedTopBarTheme,
                options: {
                  TopBarTheme.rounded: labels.app_bar_theme_rounded,
                  TopBarTheme.squared: labels.app_bar_theme_square,
                  TopBarTheme.seamless: labels.app_bar_theme_seamless,
                },
                onChanged: (value) {
                  settings.setPreference('topbar_theme', value.index);
                  theme.setSelectedTopBarTheme(value);
                },
              ),
            ],
          ),
          SettingsSection(
            title: labels.tabs,
            children: [
              SettingsToggle(
                title: labels.show_tab_label,
                value: settings.isShowTabLabel,
                onChanged: settings.showTabLabels,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorDialog extends StatefulWidget {
  const _ColorDialog({required this.initialValue});
  final String initialValue;
  @override
  State<_ColorDialog> createState() => _ColorDialogState();
}

class _ColorDialogState extends State<_ColorDialog> {
  bool invalid = false;
  late final controller = TextEditingController(text: widget.initialValue);
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(AppLocalizations.of(context)!.accent_color),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final color in [
              Colors.blue,
              Colors.indigo,
              Colors.deepPurple,
              Colors.pink,
              Colors.teal,
              Colors.green,
              Colors.orange,
              Colors.red,
            ])
              IconButton(
                onPressed: () => Navigator.pop(context, color),
                icon: Icon(Icons.circle, color: color, size: 32),
              ),
          ],
        ),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: '#RRGGBB / #AARRGGBB',
            errorText: invalid
                ? AppLocalizations.of(context)!.invalid_hex_color
                : null,
          ),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
      ),
      TextButton(
        onPressed: () {
          final text = controller.text.trim().replaceFirst('#', '');
          if (!RegExp(r'^(?:[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$').hasMatch(text)) {
            setState(() => invalid = true);
            return;
          }
          Navigator.pop(
            context,
            Color(int.parse(text.length == 6 ? 'ff$text' : text, radix: 16)),
          );
        },
        child: Text(MaterialLocalizations.of(context).okButtonLabel),
      ),
    ],
  );
}
