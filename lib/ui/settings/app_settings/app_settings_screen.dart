import 'package:flutter/material.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:player/data/settings.dart';
import 'package:provider/provider.dart';

class AppGeneralSettingsScreen extends StatefulWidget {
  const AppGeneralSettingsScreen({Key? key}) : super(key: key);

  @override
  AppGeneralSettingsScreenState createState() =>
      AppGeneralSettingsScreenState();
}

class AppGeneralSettingsScreenState extends State<AppGeneralSettingsScreen> {
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
            title: AppLocalizations.of(context)!.general_settings,
            children: [
              Consumer<PlayerSettings>(
                builder: (context, value, child) {
                  List<Locale> locales = AppLocalizations.supportedLocales;

                  return DropDownSettingsTile<String>(
                    leading: const Icon(Icons.translate),
                    title: AppLocalizations.of(context)!.language_sett,
                    settingKey: "language",
                    selected: (value.getAppLocale != null)
                        ? value.getAppLocale!.countryCode ?? "en"
                        : "en",
                    onChange: (p0) {
                      PlayerSettings.instance.setLocale(
                        Locale.fromSubtags(languageCode: p0),
                      );
                    },
                    values: {
                      for (var element in locales)
                        element.languageCode: element.languageCode,
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
