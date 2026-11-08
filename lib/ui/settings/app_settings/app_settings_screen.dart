import 'package:flutter/material.dart';
import 'package:player/data/settings.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/ui/settings/settings_controls.dart';
import 'package:player/ui/settings/settings_section.dart';
import 'package:provider/provider.dart';

class AppGeneralSettingsScreen extends StatelessWidget {
  const AppGeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context)!;
    final settings = context.watch<PlayerSettings>();
    return SafeArea(
      child: AdaptiveSettingsScreen(
        title: labels.app_sett,
        children: [
          SettingsSection(
            title: labels.general_settings,
            children: [
              SettingsChoice<String>(
                title: labels.language_sett,
                value: settings.getAppLocale?.languageCode ?? 'en',
                options: {
                  for (final locale in AppLocalizations.supportedLocales)
                    locale.languageCode: locale.languageCode,
                },
                onChanged: (value) => settings.setLocale(Locale(value)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
