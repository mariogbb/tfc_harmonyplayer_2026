import 'package:flutter/material.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/ui/settings/menu_entries.dart';
import 'package:player/data/data.dart';
import 'package:player/ui/settings/settings_section.dart';
import 'package:player/ui/core/desktop_content_scope.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({Key? key, this.onReload}) : super(key: key);
  final Future<void> Function()? onReload;

  @override
  AppSettingsScreenState createState() => AppSettingsScreenState();
}

class AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _reloading = false;

  Future<void> _reload() async {
    if (_reloading) return;
    setState(() => _reloading = true);
    try {
      await (widget.onReload ??
          PlayerData.instance.refreshCoordinator.refresh)();
    } finally {
      if (mounted) setState(() => _reloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        appBar: DesktopContentScope.isActive(context)
            ? null
            : AppBar(title: Text(AppLocalizations.of(context)!.settings)),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 700 ? 2 : 1;
                final width = constraints.maxWidth / columns;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        children: [
                          for (final entry in menuEntries(context))
                            SizedBox(width: width, child: entry),
                        ],
                      ),
                      SettingsSection(
                        title: AppLocalizations.of(context)!.general_settings,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.refresh_rounded),
                            title: Text(
                              AppLocalizations.of(context)!.reload_songs,
                            ),
                            trailing: _reloading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.chevron_right_rounded),
                            onTap: _reloading ? null : _reload,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
