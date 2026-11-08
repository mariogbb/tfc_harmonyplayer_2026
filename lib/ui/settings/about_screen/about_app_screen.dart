import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/ui/settings/settings_section.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key, this.launchEmail});
  final Future<bool> Function(Uri)? launchEmail;

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return SafeArea(
      child: AdaptiveSettingsScreen(
        title: labels.about,
        children: [
          SettingsSection(
            title: 'Harmony Player',
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.primaryColor.withValues(alpha: 0.14),
                  child: Icon(
                    Icons.graphic_eq_rounded,
                    color: theme.primaryColor,
                  ),
                ),
                title: Text(labels.app_version),
                subtitle: FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) => snapshot.hasData
                      ? Text(snapshot.data!.version)
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: labels.bugs_and_features,
            children: [
              ListTile(
                leading: const Icon(Icons.bug_report_outlined),
                title: Text(labels.report_a_bug),
                enabled: false,
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('mario.besada.dev@gmail.com'),
                subtitle: Text(labels.contact),
                onTap: () => (launchEmail ?? launchUrl)(
                  Uri(scheme: 'mailto', path: 'mario.besada.dev@gmail.com'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
