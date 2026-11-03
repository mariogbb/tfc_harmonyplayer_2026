import 'package:flutter/material.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:player/ui/core/generic_artwork.dart';

class PlayingScreenSettings extends StatefulWidget {
  const PlayingScreenSettings({Key? key}) : super(key: key);

  @override
  PlayingScreenSettingsState createState() => PlayingScreenSettingsState();
}

class PlayingScreenSettingsState extends State<PlayingScreenSettings> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: SettingsScreen(
        title: AppLocalizations.of(context)!.playing_screen_sett,
        children: [
          SettingsGroup(
            title: AppLocalizations.of(context)!.look_and_feel,
            children: [
              DropDownSettingsTile<int>(
                title: AppLocalizations.of(context)!
                    .playing_screen_artwork_shape,
                settingKey: "playing_artwork_shape",
                selected: ArtworkShape.circle.index,
                values: <int, String>{
                  ArtworkShape.circle.index: AppLocalizations.of(context)!
                      .playing_screen_artwork_shape_circle,
                  ArtworkShape.square.index: AppLocalizations.of(context)!
                      .playing_screen_artwork_shape_square,
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
