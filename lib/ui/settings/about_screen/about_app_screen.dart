import 'package:flutter/material.dart';
import 'package:player/ui/settings/about_screen/changelog_dialogs.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/ui/settings/about_screen/contact_dialog.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({Key? key}) : super(key: key);

  AppBar _getAppbar(BuildContext context) {
    return AppBar(title: Text(AppLocalizations.of(context)!.about));
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.headlineSmall!
        .copyWith(color: Theme.of(context).primaryColor);

    return SafeArea(
      top: true,
      child: Scaffold(
        extendBody: false,
        appBar: _getAppbar(context),
        extendBodyBehindAppBar: false,
        body: SafeArea(
          bottom: true,
          child: Center(
            heightFactor: 1,
            child: SingleChildScrollView(
              child: ListView(
                padding: const EdgeInsets.only(left: 20),
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                children: [
                  ListTile(
                    title: Text(
                      AppLocalizations.of(context)!.bugs_and_features,
                      style: titleStyle,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.bug_report_outlined),
                    title: Text(AppLocalizations.of(context)!.report_a_bug),
                  ),
                  GestureDetector(
                    onTap: () => ContactDialog.showContactDialog(context),
                    child: ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: Text(AppLocalizations.of(context)!.contact),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      AppLocalizations.of(context)!.others,
                      style: titleStyle,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(AppLocalizations.of(context)!.app_version),
                    subtitle: const Text("0.3.73"),
                  ),
                  GestureDetector(
                    onTap: () {
                      AppChangelogDialogs.launchChangelogDialog(context);
                    },
                    child: ListTile(
                      leading: const Icon(Icons.list_alt),
                      title: Text(AppLocalizations.of(context)!.changelog),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
