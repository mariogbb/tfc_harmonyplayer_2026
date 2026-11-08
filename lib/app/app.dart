import 'package:flutter/material.dart';
import 'package:player/app/home_page.dart';
import 'package:player/data/data.dart';
import 'package:player/data/settings.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/ui/library/albums/album_screen.dart';
import 'package:player/ui/library/artists/artist_screen.dart';
import 'package:player/ui/playlists/single_playlist_screen.dart';
import 'package:player/ui/rankings/top_played_albums.dart';
import 'package:player/ui/rankings/top_played_songs.dart';
import 'package:player/ui/search/search_overlay.dart';
import 'package:player/ui/settings/settings_screen.dart';
import 'package:player/theme_data/dark_theme.dart';
import 'package:player/theme_data/light_theme.dart';
import 'package:player/theme_data/theme_provider.dart';
import 'package:provider/provider.dart';

import 'dart:async';

import 'package:player/app/app_resources.dart';

class HarmonyApp extends StatefulWidget {
  const HarmonyApp({super.key});

  @override
  State<HarmonyApp> createState() => _HarmonyAppState();
}

class _HarmonyAppState extends State<HarmonyApp> {
  @override
  void dispose() {
    unawaited(
      AppResources.instance.dispose().catchError((
        Object error,
        StackTrace stack,
      ) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: 'application shutdown',
          ),
        );
      }),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: PlayerData.instance.playlistController,
        ),
        ChangeNotifierProvider.value(
          value: PlayerData.instance.libraryController,
        ),
        ChangeNotifierProvider.value(value: PlayerData.instance.handler),
        ChangeNotifierProvider(
          create: (context) =>
              ThemeProvider(AppResources.instance.settings.store),
        ),
        ChangeNotifierProvider.value(value: AppResources.instance.settings),
      ],
      child: Consumer2<ThemeProvider, PlayerSettings>(
        child: HomePage(),
        builder: (context, themeValue, settingsValue, child) {
          return MaterialApp(
            themeMode: themeValue.selectedThemeMode,
            theme: LightTheme.getTheme(
              themeValue.selectedPrimaryColor,
              themeValue.selectedTopBarTheme,
            ),
            darkTheme: DarkTheme.getTheme(
              themeValue.selectedPrimaryColor,
              themeValue.selectedTopBarTheme,
            ),
            debugShowCheckedModeBanner: false,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            locale: settingsValue.getAppLocale,
            title: 'Harmony Player',
            color: themeValue.selectedPrimaryColor,
            home: child,
            routes: {
              'search': (context) => const SearchOverlayTab(),
              'album': (context) => const AlbumScreen(),
              'artist': (context) => const ArtistScreen(),
              'playlist': (context) => const SinglePlaylistScreen(),
              'settings': (context) => const AppSettingsScreen(),
              'top_played_albums': (context) => const TopAlbumsRanking(),
              'top_played_songs': (context) => const TopSongsRanking(),
            },
          );
        },
      ),
    );
  }
}
