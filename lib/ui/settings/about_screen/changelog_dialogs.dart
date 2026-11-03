import 'package:flutter/material.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:flutter/services.dart' show rootBundle;

class AppChangelogDialogs {
  static void launchChangelogDialog(BuildContext context) async {
    String data = await rootBundle.loadString("assets/changelog");
    if (!context.mounted) return;
    List<String> changeLog = data.split("\n");

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: ListView(
                children: [
                  ListTile(
                    title: Text(
                      "${AppLocalizations.of(context)!.changelog}: ",
                      style: Theme.of(context).textTheme.displaySmall!
                          .copyWith(fontSize: 36),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: changeLog.length,
                    itemBuilder: (context, index) {
                      String str = changeLog[index];

                      if (str.startsWith("version: ")) {
                        str = str.substring(8, str.length);

                        return ListTile(
                          title: Text(
                            str,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        );
                      }

                      return ListTile(title: Text("- $str"));
                    },
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
