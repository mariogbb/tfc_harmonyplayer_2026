import 'package:flutter/material.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:player/data/settings.dart';
import 'package:player/theme_data/theme_provider.dart';
import 'package:player/theme_data/top_bar_theme.dart';
import 'package:player/ui/core/generic_artwork.dart';
import 'package:provider/provider.dart';

class LookAndFeelScreen extends StatefulWidget {
  const LookAndFeelScreen({Key? key}) : super(key: key);

  @override
  LookAndFeelScreenState createState() => LookAndFeelScreenState();
}

class LookAndFeelScreenState extends State<LookAndFeelScreen> {
  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.headlineSmall!
        .copyWith(color: Theme.of(context).primaryColor);

    return SafeArea(
      top: true,
      child: SettingsScreen(
        title: AppLocalizations.of(context)!.look_and_feel,
        children: [
          SettingsGroup(
            titleTextStyle: titleStyle,
            title: AppLocalizations.of(context)!.color_scheme,
            children: [
              Consumer<ThemeProvider>(
                builder: (context, value, child) {
                  return ColorPickerSettingsTile(
                    title: AppLocalizations.of(context)!.accent_color,
                    settingKey: "accent_color",
                    defaultStringValue:
                        "#${value.selectedPrimaryColor.toARGB32().toRadixString(16)}",
                    onChange: (p0) {
                      value.setSelectedPrimaryColor(p0);
                    },
                  );
                },
              ),
              Consumer<ThemeProvider>(
                builder: (context, value, child) {
                  return DropDownSettingsTile<int>(
                    title: AppLocalizations.of(context)!.color_mode,
                    settingKey: "color_mode",
                    selected: value.selectedThemeMode.index,
                    onChange: (p0) {
                      ThemeMode mode = ThemeMode.values[p0];

                      value.setSelectedThemeMode(mode);
                    },
                    values: <int, String>{
                      0: AppLocalizations.of(context)!.color_mode_system,
                      1: AppLocalizations.of(context)!.color_mode_ligth,
                      2: AppLocalizations.of(context)!.color_mode_dark,
                    },
                  );
                },
              ),
            ],
          ),
          SettingsGroup(
            titleTextStyle: titleStyle,
            title: AppLocalizations.of(context)!.songs_sett,
            children: [
              DropDownSettingsTile<int>(
                title: AppLocalizations.of(context)!.song_artwork_shape,
                settingKey: "song_artwork_shape",
                selected: ArtworkShape.circle.index,
                values: <int, String>{
                  ArtworkShape.circle.index: AppLocalizations.of(context)!
                      .song_artwork_shape_circle,
                  ArtworkShape.square.index: AppLocalizations.of(context)!
                      .song_artwork_shape_square,
                },
              ),
              SwitchSettingsTile(
                title: AppLocalizations.of(context)!.show_tab_label,
                settingKey: "show_songs_time_label",
                defaultValue: false,
                onChange: (p0) {
                  PlayerSettings.instance.setShowSongTimeLabel(p0);
                },
              ),
            ],
          ),
          SettingsGroup(
            titleTextStyle: titleStyle,
            title: AppLocalizations.of(context)!.album_tab_sett,
            children: [
              DropDownSettingsTile<int>(
                title: AppLocalizations.of(context)!.album_artwork_shape,
                settingKey: "albumtab_artwork_shape",
                selected: ArtworkShape.circle.index,
                values: <int, String>{
                  ArtworkShape.circle.index: AppLocalizations.of(context)!
                      .album_artwork_shape_circle,
                  ArtworkShape.square.index: AppLocalizations.of(context)!
                      .album_artwork_shape_square,
                },
              ),
            ],
          ),
          SettingsGroup(
            titleTextStyle: titleStyle,
            title: AppLocalizations.of(context)!.app_bar_sett,
            children: [
              Consumer<ThemeProvider>(
                builder: (context, value, child) {
                  return DropDownSettingsTile<int>(
                    title: AppLocalizations.of(context)!.app_bar_theme,
                    settingKey: "topbar_theme",
                    selected: TopBarTheme.rounded.index,
                    onChange: (p0) {
                      value.setSelectedTopBarTheme(TopBarTheme.values[p0]);
                    },
                    values: <int, String>{
                      TopBarTheme.rounded.index: AppLocalizations.of(context)!
                          .app_bar_theme_rounded,
                      TopBarTheme.squared.index: AppLocalizations.of(context)!
                          .app_bar_theme_square,
                      TopBarTheme.seamless.index: AppLocalizations.of(context)!
                          .app_bar_theme_seamless,
                    },
                  );
                },
              ),
            ],
          ),
          SettingsGroup(
            titleTextStyle: titleStyle,
            title: AppLocalizations.of(context)!.tabs,
            children: [
              SwitchSettingsTile(
                title: AppLocalizations.of(context)!.show_tab_label,
                settingKey: "show_tab_label",
                defaultValue: false,
                onChange: (p0) {
                  PlayerSettings.instance.showTabLabels(p0);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
