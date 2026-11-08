import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/control/media_control.dart';
import 'package:player/data/data.dart';
import 'package:player/data/repositories/artwork_repository.dart';
import 'package:player/data/services/artwork/local_artwork_service.dart';
import 'package:player/data/settings.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';
import 'package:player/model/library_metadata.dart';
import 'package:player/model/song.dart';
import 'package:player/theme_data/light_theme.dart';
import 'package:player/theme_data/dark_theme.dart';
import 'package:player/theme_data/neo_style.dart';
import 'package:player/theme_data/top_bar_theme.dart';
import 'package:player/ui/home/menu_tab.dart';
import 'package:player/ui/library/albums/albums_tab.dart';
import 'package:player/ui/library/library_controller.dart';
import 'package:player/ui/library/songs/songs_tab.dart';
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

Future<ui.Image> _coverImage(Color color, int index) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(const Rect.fromLTWH(0, 0, 256, 256), Paint()..color = color);
  canvas.drawCircle(
    Offset(65 + index * 20.0, 100),
    70,
    Paint()..color = Colors.white.withValues(alpha: .3),
  );
  canvas.drawRect(
    const Rect.fromLTWH(35, 175, 186, 8),
    Paint()..color = Colors.white.withValues(alpha: .7),
  );
  canvas.drawRect(
    const Rect.fromLTWH(35, 195, 110, 8),
    Paint()..color = Colors.white.withValues(alpha: .4),
  );
  return recorder.endRecording().toImage(256, 256);
}

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
    final settings = PlayerSettings(FakeSettingsStore());
    final handler = PlayerHandler.withBackend(FakeBackend(), (_, _) async {});
    PlayerData.instance.handler = handler;
    addTearDown(library.dispose);
    addTearDown(settings.dispose);
    addTearDown(handler.dispose);
    const colors = [
      Color(0xff705d9c),
      Color(0xff50877e),
      Color(0xffb26e68),
      Color(0xff547aaa),
      Color(0xffab8c5b),
    ];
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
        final bytes = (await tester.runAsync(() async {
          final image = await _coverImage(
            colors[albumIndex % colors.length],
            albumIndex,
          );
          final bytes = (await image.toByteData(
            format: ui.ImageByteFormat.png,
          ))!.buffer.asUint8List();
          image.dispose();
          return bytes;
        }))!;
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
    final boundaryKey = GlobalKey();
    for (final (device, size) in <(String, Size)>[
      ('desktop', const Size(1200, 900)),
      ('mobile', const Size(390, 844)),
    ]) {
      tester.view.physicalSize = size;
      for (final dark in [false, true]) {
        for (final (name, page) in <(String, Widget)>[
          ('dashboard', const PlayerMenuTab()),
          ('albums', const PlayerAlbumTab()),
          ('songs', const PlayerSongsTab()),
        ]) {
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider<LibraryController>.value(value: library),
                ChangeNotifierProvider.value(value: settings),
                ChangeNotifierProvider.value(value: handler),
              ],
              child: MaterialApp(
                theme: dark
                    ? DarkTheme.getTheme(
                        NeoStyle.darkDefaultAccent,
                        TopBarTheme.seamless,
                      )
                    : LightTheme.getTheme(
                        NeoStyle.defaultAccent,
                        TopBarTheme.seamless,
                      ),
                locale: const Locale('en'),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: RepaintBoundary(
                  key: boundaryKey,
                  child: Scaffold(body: page),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          if (output.isNotEmpty) {
            final context = boundaryKey.currentContext!;
            await tester.runAsync(() async {
              await Future.wait(
                library.albums.map(
                  (album) => precacheImage(MemoryImage(album.artwork), context),
                ),
              );
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
  });
}
