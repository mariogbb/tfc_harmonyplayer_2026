import 'package:flutter/material.dart';
import 'package:player/data/settings.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/ui/settings/settings_controls.dart';
import 'package:player/ui/settings/settings_section.dart';
import 'package:provider/provider.dart';

class SongSettingsScreen extends StatelessWidget {
  const SongSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context)!;
    final settings = context.watch<PlayerSettings>();
    return SafeArea(
      child: AdaptiveSettingsScreen(
        title: labels.song_settings,
        children: [
          SettingsSection(
            title: labels.filters,
            children: [
              SettingsToggle(
                title: labels.smart_filter_sett,
                subtitle: labels.smart_filter_sett_desc,
                value: settings.isSmartFilterEnabled,
                onChanged: settings.setSmartFilterEnabled,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labels.minimum_song_lenght_sett,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      labels.minimum_song_lenght_sett_desc,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            min: 0,
                            max: 120,
                            divisions: 120,
                            value: settings.getFilterDuration.clamp(0, 120),
                            onChanged: settings.setFilterDuration,
                          ),
                        ),
                        Text('${settings.getFilterDuration.round()} s'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
