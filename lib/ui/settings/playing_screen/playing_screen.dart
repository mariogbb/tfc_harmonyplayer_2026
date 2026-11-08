import 'package:flutter/material.dart';
import 'package:player/data/settings.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/ui/core/generic_artwork.dart';
import 'package:player/ui/settings/settings_controls.dart';
import 'package:player/ui/settings/settings_section.dart';
import 'package:provider/provider.dart';

class PlayingScreenSettings extends StatelessWidget {
  const PlayingScreenSettings({super.key});
  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context)!;
    final settings = context.watch<PlayerSettings>();
    return SafeArea(
      child: AdaptiveSettingsScreen(
        title: labels.playing_screen_sett,
        children: [
          SettingsSection(
            title: labels.look_and_feel,
            children: [
              SettingsChoice<int>(
                title: labels.playing_screen_artwork_shape,
                value: settings.store.read<int>(
                  'playing_artwork_shape',
                  defaultValue: ArtworkShape.circle.index,
                )!,
                options: {
                  ArtworkShape.circle.index:
                      labels.playing_screen_artwork_shape_circle,
                  ArtworkShape.square.index:
                      labels.playing_screen_artwork_shape_square,
                },
                onChanged: (value) =>
                    settings.setPreference('playing_artwork_shape', value),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
