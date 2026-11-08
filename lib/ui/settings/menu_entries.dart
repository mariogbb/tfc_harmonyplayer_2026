import 'package:flutter/material.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/ui/settings/about_screen/about_app_screen.dart';
import 'package:player/ui/settings/app_settings/app_settings_screen.dart';
import 'package:player/ui/settings/look_and_feel/look_and_feel.dart';
import 'package:player/ui/settings/song_settings/song_settings.dart';
import 'package:player/ui/core/library_row.dart';

List<Widget> menuEntries(BuildContext context) {
  return [
    menuEntry(
      titleText: AppLocalizations.of(context)!.look_and_feel,
      subTitleText: AppLocalizations.of(context)!.look_and_feel_desc,
      leadingIcon: Icons.palette,
      onClick: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            settings: const RouteSettings(name: 'settings/appearance'),
            builder: (context) => const LookAndFeelScreen(),
          ),
        );
      },
      context: context,
    ),
    menuEntry(
      titleText: AppLocalizations.of(context)!.song_settings,
      subTitleText: AppLocalizations.of(context)!.song_sett_desc,
      leadingIcon: Icons.music_note,
      onClick: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            settings: const RouteSettings(name: 'settings/songs'),
            builder: (context) => const SongSettingsScreen(),
          ),
        );
      },
      context: context,
    ),
    menuEntry(
      titleText: AppLocalizations.of(context)!.app_sett,
      subTitleText: AppLocalizations.of(context)!.app_sett_desc,
      leadingIcon: Icons.app_settings_alt,
      onClick: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            settings: const RouteSettings(name: 'settings/general'),
            builder: (context) => const AppGeneralSettingsScreen(),
          ),
        );
      },
      context: context,
    ),
    menuEntry(
      titleText: AppLocalizations.of(context)!.about,
      subTitleText: AppLocalizations.of(context)!.about_desc,
      leadingIcon: Icons.info_outlined,
      onClick: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            settings: const RouteSettings(name: 'settings/about'),
            builder: (context) => const AboutAppScreen(),
          ),
        );
      },
      context: context,
    ),
  ];
}

Widget menuEntry({
  required String titleText,
  required String subTitleText,
  required IconData leadingIcon,
  required VoidCallback onClick,
  required BuildContext context,
}) {
  return LibraryRow(
    child: ListTile(
      onTap: onClick,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.14),
        foregroundColor: Theme.of(context).primaryColor,
        child: Icon(leadingIcon),
      ),
      title: Text(
        titleText,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(subTitleText),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}
