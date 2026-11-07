import 'package:flutter/material.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:player/data/settings.dart';
import 'package:provider/provider.dart';

class SongSettingsScreen extends StatefulWidget {
  const SongSettingsScreen({Key? key}) : super(key: key);

  @override
  SongSettingsScreenState createState() => SongSettingsScreenState();
}

class SongSettingsScreenState extends State<SongSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.headlineSmall!
        .copyWith(color: Theme.of(context).primaryColor);

    return SafeArea(
      top: true,
      child: SettingsScreen(
        title: AppLocalizations.of(context)!.song_settings,
        children: [
          SettingsGroup(
            titleTextStyle: titleStyle,
            title: AppLocalizations.of(context)!.filters,
            children: [
              Consumer<PlayerSettings>(
                builder: (context, value, child) {
                  return SwitchSettingsTile(
                    title: AppLocalizations.of(context)!.smart_filter_sett,
                    subtitle: AppLocalizations.of(context)!
                        .smart_filter_sett_desc,
                    settingKey: "smartFilterEnabled",
                    onChange: value.setSmartFilterEnabled,
                  );
                },
              ),
              Consumer<PlayerSettings>(
                builder: (context, value, child) {
                  return SliderSettingsTile(
                    max: 120,
                    min: 0,
                    step: 1,
                    title: AppLocalizations.of(context)!
                        .minimum_song_lenght_sett,
                    subtitle: AppLocalizations.of(context)!
                        .minimum_song_lenght_sett_desc,
                    settingKey: "filterDuration",
                    onChange: (p0) {
                      value.setFilterDuration(p0);
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
