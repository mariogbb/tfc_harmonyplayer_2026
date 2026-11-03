import 'package:flutter/material.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:player/data/settings.dart';

class UserNameDialog {
  static changeUserNameDialog(BuildContext context) {
    String text = Settings.getValue<String>("user_name") ?? "user";
    bool error = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.white54,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      AppLocalizations.of(context)!.change_user_name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    child: TextField(
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.go,
                      maxLength: 25,
                      onSubmitted: (value) {
                        if (text.isEmpty) {
                          setState(() => error = true);
                        } else {
                          PlayerSettings.instance.setUserName(text);
                          Navigator.of(context).pop();
                        }
                      },
                      decoration: InputDecoration(
                        label: Text(
                          AppLocalizations.of(context)!.new_user_name,
                        ),
                        errorText: (error)
                            ? AppLocalizations.of(context)!.field_cannot_empty
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() => text = value);
                        setState(() => error = false);
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (text.isEmpty) {
                        setState(() => error = true);
                      } else {
                        PlayerSettings.instance.setUserName(text);
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.change),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
