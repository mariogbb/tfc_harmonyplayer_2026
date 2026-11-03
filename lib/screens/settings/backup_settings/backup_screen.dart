import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class BackupSettingsScreen extends StatelessWidget {
  const BackupSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Theme.of(context)
        .textTheme
        .headlineSmall!
        .copyWith(color: Theme.of(context).primaryColor);

    return SafeArea(
      top: true,
      child: SettingsScreen(
        title: AppLocalizations.of(context)!.backup_sett,
        children: [
          SettingsGroup(
            titleTextStyle: titleStyle,
            title: AppLocalizations.of(context)!.backup_sett,
            children: [
              ListTile(
                title: const Text("Export"),
                trailing: OutlinedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  child: const Icon(Icons.upload),
                ),
              ),
              ListTile(
                title: const Text("Import"),
                trailing: OutlinedButton(
                  onPressed: () async {
                    String? path = await FilesystemPicker.open(
                        context: context,
                        rootDirectory: Directory("/storage/emulated/0"));

                    if (path != null) {
                      if (path.endsWith("player_db.db")) {}
                    }
                  },
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  child: const Icon(Icons.restore),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
