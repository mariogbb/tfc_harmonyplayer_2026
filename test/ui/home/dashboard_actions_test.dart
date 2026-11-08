import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/control/media_control.dart';
import 'package:player/data/data.dart';
import 'package:player/data/repositories/artwork_repository.dart';
import 'package:player/data/services/artwork/fallback_artwork.dart';
import 'package:player/data/services/artwork/local_artwork_service.dart';
import 'package:player/data/settings.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';
import 'package:player/model/library_metadata.dart';
import 'package:player/model/play_context.dart';
import 'package:player/model/song.dart';
import 'package:player/ui/home/menu_tab.dart';
import 'package:player/ui/library/library_controller.dart';
import 'package:provider/provider.dart';

import '../../control/player_handler_test.dart' show FakeBackend;
import '../../data/player_settings_test.dart' show FakeSettingsStore;
import '../library/library_tabs_test.dart'
    show FakeArtworkCache, FakeArtworkSearch, FakeLibraryRepository;

class _Library extends LibraryController {
  _Library()
    : super(
        repository: FakeLibraryRepository(),
        artworkRepository: ArtworkRepository(
          cache: FakeArtworkCache(),
          search: FakeArtworkSearch(),
        ),
        localArtwork: LocalArtworkService(),
      );
  List<SongData> songs = [];
  List<AlbumData> albums = [];
  @override
  List<SongData> get songList => songs;
  @override
  List<AlbumData> get albumList => albums;
}

void main() {
  testWidgets('top album opens its album and top song starts the ranked queue', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final artistList = <ArtistData>[];
    final album = AlbumData(
      const AlbumMetadata(id: 4, album: 'Test album', artist: 'Band'),
      artwork: fallbackArtwork,
      songs: [],
      artists: artistList,
    );
    SongData song(int id, int seconds) => SongData(
      model: SongMetadata(
        id: id,
        data: '/$id.mp3',
        title: 'Track $id',
        artist: 'Band',
      ),
      albumModel: album,
      playedTime: Duration(seconds: seconds),
      artists: artistList,
    );
    final library = _Library()
      ..albums = [album]
      ..songs = [song(1, 5), song(2, 20)];
    final settings = PlayerSettings(FakeSettingsStore());
    final handler = PlayerHandler.withBackend(FakeBackend(), (_, _) async {});
    PlayerData.instance.handler = handler;
    addTearDown(library.dispose);
    addTearDown(settings.dispose);
    addTearDown(handler.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LibraryController>.value(value: library),
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: handler),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: PlayerMenuTab()),
          routes: {
            'album': (context) => Scaffold(
              body: Text(
                'Opened ${(ModalRoute.of(context)!.settings.arguments as AlbumData).name}',
              ),
            ),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test album'));
    await tester.pumpAndSettle();
    expect(find.text('Opened Test album'), findsOneWidget);
    Navigator.of(tester.element(find.text('Opened Test album'))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Track 2'));
    await tester.pump();
    expect(handler.playingSong!.id, 2);
    expect(handler.getPlayingContext!.getContext, ContextType.topPlayedSongs);
    expect(handler.getCompleteQueue.map((song) => song.id), [2, 1]);
  });
}
