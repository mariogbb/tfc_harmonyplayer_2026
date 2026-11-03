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

class HarmonyApp extends StatelessWidget {
  const HarmonyApp({super.key, required this.showWelcome});

  final bool showWelcome;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: PlayerData.instance),
        ChangeNotifierProvider.value(value: PlayerData.instance.handler),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider.value(value: PlayerSettings.instance),
      ],
      child: Consumer2<ThemeProvider, PlayerSettings>(
        child: HomePage(showWelcome: showWelcome),
        builder: (context, themeValue, settingsValue, child) {
          return MaterialApp(
            themeMode: themeValue.selectedThemeMode,
            theme: LightTheme.getTheme(themeValue.selectedPrimaryColor),
            darkTheme: DarkTheme.getTheme(themeValue.selectedPrimaryColor),
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
