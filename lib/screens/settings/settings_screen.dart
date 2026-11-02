import 'package:flutter/material.dart';
import 'package:player/l10n/app_localizations.dart';
import 'menu_entries.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({Key? key}) : super(key: key);

  @override
  AppSettingsScreenState createState() => AppSettingsScreenState();
}

class AppSettingsScreenState extends State<AppSettingsScreen> {
  int selectedColor = 5;
  double minimumLength = 30;
  bool usingFilters = false;
  bool loadArtistImages = true;
  bool loadAlbumArtwork = true;
  int colorMode = 1;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.settings),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: ListView(
            children: menuEntries(context),
          ),
        ),
      ),
    );
  }
}
