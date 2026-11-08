import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/control/media_control.dart';
import 'package:player/app/home_page.dart';
import 'package:player/data/data.dart';
import 'package:player/data/repositories/music_library_repository.dart';
import 'package:player/data/repositories/playlist_repository.dart';
import 'package:player/data/repositories/artwork_repository.dart';
import 'package:player/data/services/artwork/local_artwork_service.dart';
import 'package:player/data/settings.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';
import 'package:player/model/library_metadata.dart';
import 'package:player/model/song.dart';
import 'package:player/model/playlist.dart';
import 'package:player/model/play_context.dart';
import 'package:player/theme_data/theme_provider.dart';
import 'package:player/theme_data/light_theme.dart';
import 'package:player/theme_data/dark_theme.dart';
import 'package:player/theme_data/neo_style.dart';
import 'package:player/theme_data/top_bar_theme.dart';
import 'package:player/ui/library/library_controller.dart';
import 'package:player/ui/core/desktop_navigation.dart';
import 'package:provider/provider.dart';

import '../control/player_handler_test.dart' show FakeBackend;
import '../data/player_settings_test.dart' show FakeSettingsStore;
import '../ui/library/library_tabs_test.dart'
    show FakeArtworkCache, FakeArtworkSearch, FakeLibraryRepository;

// Test-only metadata. Paths are deliberately nonexistent and never opened.
const _records = [
  ('Dreams', 'Fleetwood Mac', 'Rumours', 1977, 257000),
  ('Go Your Own Way', 'Fleetwood Mac', 'Rumours', 1977, 218000),
  ('Here Comes the Sun', 'The Beatles', 'Abbey Road', 1969, 185000),
  ('Come Together', 'The Beatles', 'Abbey Road', 1969, 259000),
  ('Billie Jean', 'Michael Jackson', 'Thriller', 1982, 294000),
  ('Beat It', 'Michael Jackson', 'Thriller', 1982, 258000),
  ('Heroes', 'David Bowie', 'Heroes', 1977, 371000),
  ('Space Oddity', 'David Bowie', 'Space Oddity', 1969, 315000),
];

class _ScreenshotLibrary extends LibraryController {
  _ScreenshotLibrary()
    : super(
        repository: FakeLibraryRepository(),
        artworkRepository: ArtworkRepository(
          cache: FakeArtworkCache(),
          search: FakeArtworkSearch(),
        ),
        localArtwork: LocalArtworkService(),
      );
  final songs = <SongData>[];
  final albums = <AlbumData>[];
  final artists = <ArtistData>[];
  @override
  List<SongData> get songList => songs;
  @override
  List<AlbumData> get albumList => albums;
  @override
  List<ArtistData> get artistList => artists;
}

class _EmptyRepository implements MusicLibraryRepository {
  @override
  Future<MusicLibrary> load({
    required bool smartFilterEnabled,
    required int minimumDurationSeconds,
  }) async => const MusicLibrary(songs: [], albums: [], artists: []);
}

class _EmptyPlaylists implements PlaylistRepository {
  @override
  Future<List<PlaylistData>> load(List<SongData> songs) async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const coverDir = String.fromEnvironment('DEEZER_COVER_DIR');

void main() {
  testWidgets('render isolated product screenshot fixtures', (tester) async {
    const output = String.fromEnvironment('SCREENSHOT_DIR');
    final previousShadows = debugDisableShadows;
    if (output.isNotEmpty) {
      debugDisableShadows = false;
      addTearDown(() => debugDisableShadows = previousShadows);
      final textFont = FontLoader('Roboto')
        ..addFont(rootBundle.load('fonts/Inter-Regular.ttf'));
      final iconFont = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await textFont.load();
      await iconFont.load();
    }
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final library = _ScreenshotLibrary();
    final store = FakeSettingsStore();
    final settings = PlayerSettings(store);
    final themeProvider = ThemeProvider(store);
    final handler = PlayerHandler.withBackend(FakeBackend(), (_, _) async {});
    PlayerData.instance.handler = handler;
    final player = PlayerData.instance;
    player.configureMusicLibrary(_EmptyRepository());
    player.configureArtwork(
      ArtworkRepository(cache: FakeArtworkCache(), search: FakeArtworkSearch()),
      LocalArtworkService(),
    );
    player.configurePlaylists(_EmptyPlaylists());
    player.configureRefreshCoordinator(store);
    addTearDown(library.dispose);
    addTearDown(settings.dispose);
    addTearDown(handler.dispose);
    addTearDown(themeProvider.dispose);
    for (final (index, record) in _records.indexed) {
      final (title, artistName, albumName, _, duration) = record;
      var artistIndex = library.artists.indexWhere((a) => a.name == artistName);
      if (artistIndex < 0) {
        artistIndex = library.artists.length;
        library.artists.add(
          ArtistData(
            ArtistMetadata(id: artistIndex + 1, artist: artistName),
            albums: library.albums,
            songs: library.songs,
          ),
        );
      }
      var albumIndex = library.albums.indexWhere((a) => a.name == albumName);
      if (albumIndex < 0) {
        albumIndex = library.albums.length;
        final bytes = (await tester.runAsync(
          () => File('$coverDir/$albumIndex.jpg').readAsBytes(),
        ))!;
        library.albums.add(
          AlbumData(
            AlbumMetadata(
              id: albumIndex + 1,
              album: albumName,
              artist: artistName,
              artistId: artistIndex + 1,
            ),
            artwork: bytes,
            songs: library.songs,
            artists: library.artists,
          ),
        );
      }
      library.songs.add(
        SongData(
          model: SongMetadata(
            id: index + 1,
            data: '/nonexistent/screenshot-$index.mp3',
            title: title,
            artist: artistName,
            artistId: artistIndex + 1,
            album: albumName,
            albumId: albumIndex + 1,
            duration: duration,
          ),
          albumModel: library.albums[albumIndex],
          artists: library.artists,
          playedTime: Duration(minutes: 100 - index * 10),
        ),
      );
    }
    handler.playSongList(
      PlayingContext('All songs', ContextType.allSongs, library.songs),
      0,
    );
    final boundaryKey = GlobalKey();
    for (final (device, size) in <(String, Size)>[
      ('desktop', const Size(1200, 900)),
      ('mobile', const Size(390, 844)),
    ]) {
      tester.view.physicalSize = size;
      for (final dark in [false, true]) {
        for (final name in ['dashboard', 'albums', 'songs']) {
          final baseTheme = dark
              ? DarkTheme.getTheme(
                  NeoStyle.darkDefaultAccent,
                  TopBarTheme.seamless,
                )
              : LightTheme.getTheme(
                  NeoStyle.defaultAccent,
                  TopBarTheme.seamless,
                );
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider<LibraryController>.value(value: library),
                ChangeNotifierProvider.value(value: settings),
                ChangeNotifierProvider.value(value: handler),
                ChangeNotifierProvider.value(value: themeProvider),
                ChangeNotifierProvider.value(value: player.playlistController),
              ],
              child: MaterialApp(
                theme: baseTheme.copyWith(
                  appBarTheme: baseTheme.appBarTheme.copyWith(
                    titleTextStyle: baseTheme.appBarTheme.titleTextStyle
                        ?.copyWith(fontFamily: 'Roboto'),
                  ),
                ),
                locale: const Locale('en'),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: RepaintBoundary(
                  key: boundaryKey,
                  child: HomePage(key: ValueKey('$device-$dark-$name')),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          if (name != 'dashboard') {
            final icon = name == 'albums' ? Icons.album : Icons.music_note;
            final target = device == 'desktop'
                ? find.descendant(
                    of: find.byType(DesktopNavigation),
                    matching: find.byIcon(icon),
                  )
                : find.descendant(
                    of: find.byType(TabBar),
                    matching: find.byIcon(icon),
                  );
            await tester.tap(target.first);
            await tester.pumpAndSettle();
          }
          if (output.isNotEmpty) {
            final context = boundaryKey.currentContext!;
            await tester.runAsync(() async {
              await Future.wait([
                precacheImage(
                  const AssetImage('assets/harmony_mark.png'),
                  context,
                ),
                ...library.albums.map(
                  (album) => precacheImage(MemoryImage(album.artwork), context),
                ),
              ]);
            });
            await tester.pumpAndSettle();
          }
          expect(library.songList, hasLength(8));
          if (output.isNotEmpty) {
            final boundary =
                boundaryKey.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            await tester.runAsync(() async {
              final image = await boundary.toImage(pixelRatio: 1);
              final png = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              image.dispose();
              await Directory(output).create(recursive: true);
              await File('$output/$device-${dark ? 'dark' : 'light'}-$name.png')
                  .writeAsBytes(png!.buffer.asUint8List());
            });
          }
        }
      }
    }
    debugDisableShadows = previousShadows;
  }, skip: coverDir.isEmpty);
}
