import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/app/home_page.dart';
import 'package:player/control/media_control.dart';
import 'package:player/data/data.dart';
import 'package:player/data/repositories/artwork_repository.dart';
import 'package:player/data/repositories/music_library_repository.dart';
import 'package:player/data/repositories/playlist_repository.dart';
import 'package:player/data/services/artwork/local_artwork_service.dart';
import 'package:player/data/settings.dart';
import 'package:player/theme_data/theme_provider.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';
import 'package:player/model/library_metadata.dart';
import 'package:player/model/playlist.dart';
import 'package:player/model/song.dart';
import 'package:player/model/top_recopilations.dart';
import 'package:player/ui/core/desktop_content_scope.dart';
import 'package:player/ui/core/desktop_navigation.dart';
import 'package:player/ui/playback/control_tab.dart';
import 'package:provider/provider.dart';

import '../control/player_handler_test.dart' show FakeBackend;
import '../data/player_settings_test.dart' show FakeSettingsStore;
import 'library/library_tabs_test.dart'
    show FakeArtworkCache, FakeArtworkSearch;

class _Library implements MusicLibraryRepository {
  @override
  Future<MusicLibrary> load({
    required bool smartFilterEnabled,
    required int minimumDurationSeconds,
  }) async => const MusicLibrary(songs: [], albums: [], artists: []);
}

class _Playlists implements PlaylistRepository {
  @override
  Future<List<PlaylistData>> load(List<SongData> songs) async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'desktop details stay inside the shell and keep the player visible',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = FakeSettingsStore();
      final settings = PlayerSettings(store);
      final theme = ThemeProvider(store);
      final handler = PlayerHandler.withBackend(FakeBackend(), (_, _) async {});
      final data = PlayerData.instance;
      data.handler = handler;
      data.configureMusicLibrary(_Library());
      data.configureArtwork(
        ArtworkRepository(
          cache: FakeArtworkCache(),
          search: FakeArtworkSearch(),
        ),
        LocalArtworkService(),
      );
      data.configurePlaylists(_Playlists());
      data.configureRefreshCoordinator(store);
      addTearDown(settings.dispose);
      addTearDown(theme.dispose);
      addTearDown(handler.dispose);
      addTearDown(data.dispose);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: settings),
            ChangeNotifierProvider.value(value: theme),
            ChangeNotifierProvider.value(value: handler),
            ChangeNotifierProvider.value(value: data.libraryController),
            ChangeNotifierProvider.value(value: data.playlistController),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: HomePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final navigator = tester.state<NavigatorState>(
        find
            .descendant(
              of: find.byType(DesktopContentScope),
              matching: find.byType(Navigator),
            )
            .first,
      );
      final bytes = await rootBundle.load('assets/no_artwork_icon.png');
      final artists = <ArtistData>[];
      final songs = <SongData>[];
      final albums = <AlbumData>[];
      final album = AlbumData(
        const AlbumMetadata(
          id: 1,
          album: 'Test album',
          artistId: 2,
          artist: 'Test artist',
        ),
        artwork: Uint8List.sublistView(bytes),
        songs: songs,
        artists: artists,
      );
      albums.add(album);
      final artist = ArtistData(
        const ArtistMetadata(id: 2, artist: 'Test artist'),
        albums: albums,
        songs: songs,
      );
      artists.add(artist);
      final song = SongData(
        model: const SongMetadata(
          id: 3,
          data: '/test.mp3',
          title: 'Test track',
          albumId: 1,
          album: 'Test album',
          artistId: 2,
          artist: 'Test artist',
          duration: 4000,
        ),
        albumModel: album,
        playedTime: Duration.zero,
        artists: artists,
      );
      songs.add(song);
      for (final (route, argument) in <(String, Object)>[
        ('playlist', PlaylistData(id: 4, name: 'Test playlist', songs: [song])),
        ('album', album),
        ('artist', artist),
      ]) {
        navigator.pushNamed(route, arguments: argument);
        await tester.pumpAndSettle();
        expect(find.byType(DesktopNavigation), findsOneWidget);
        expect(find.byKey(const Key('desktop_player_panel')), findsOneWidget);
        expect(find.byIcon(Icons.settings), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
        final action = find.text(
          route == 'playlist' ? 'Play all' : 'Shuffle play',
        );
        expect(action, findsOneWidget);
        await tester.tap(action);
        await tester.pumpAndSettle();
        expect(handler.playingSong?.id, 3);
        expect(tester.takeException(), isNull);
        navigator.pop();
        await tester.pumpAndSettle();
      }
      for (final route in ['top_played_albums', 'top_played_songs']) {
        navigator.pushNamed(
          route,
          arguments: RankingData(type: Ranking.allTime),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('desktop_player_panel')), findsOneWidget);
        expect(find.byType(PlayerControlTab), findsNothing);
        expect(find.byType(AppBar), findsOneWidget);
        expect(tester.takeException(), isNull);
        navigator.pop();
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.text('Reload songs'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(DesktopNavigation), findsOneWidget);
      expect(find.byKey(const Key('desktop_player_panel')), findsOneWidget);
      await tester.tap(find.text('Look and feel'));
      await tester.pumpAndSettle();
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Look and feel'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Reload songs'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      navigator.popUntil((route) => route.isFirst);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      expect(find.text('Search your library to get started.'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(DesktopNavigation), findsOneWidget);
      expect(find.byKey(const Key('desktop_player_panel')), findsOneWidget);
    },
  );
}
