import 'package:flutter/material.dart';
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
import 'package:player/ui/library/library_controller.dart';
import 'package:player/ui/search/search_overlay.dart';
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
  List<ArtistData> artists = [];
  @override
  List<SongData> get songList => songs;
  @override
  List<AlbumData> get albumList => albums;
  @override
  List<ArtistData> get artistList => artists;
  void refresh() => notifyListeners();
}

void main() {
  testWidgets(
    'search filters immediately, clears, updates on refresh and plays selected result',
    (tester) async {
      final bytes = await rootBundle.load('assets/no_artwork_icon.png');
      final artists = <ArtistData>[];
      final album = AlbumData(
        const AlbumMetadata(
          id: 1,
          album: 'Blue Sky',
          artist: 'The Band',
          artistId: 2,
        ),
        artwork: Uint8List.sublistView(bytes),
        songs: [],
        artists: artists,
      );
      SongData song(int id) => SongData(
        model: SongMetadata(
          id: id,
          data: '/$id',
          title: 'Sunrise',
          album: 'Blue Sky',
          artist: 'The Band',
          albumId: 1,
          artistId: 2,
        ),
        albumModel: album,
        playedTime: Duration.zero,
        artists: artists,
      );
      final library = _Library()
        ..albums = [album]
        ..songs = [song(1), song(2)];
      library.artists = [
        ArtistData(
          const ArtistMetadata(id: 2, artist: 'The Band'),
          albums: library.albums,
          songs: library.songs,
        ),
      ];
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
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SearchOverlayTab(),
          ),
        ),
      );
      expect(find.text('Search your library to get started.'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'unrelated');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(find.byType(TextField), 'Sunrise');
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
      final tracks = find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == 'Sunrise',
      );
      expect(tracks, findsNWidgets(2));
      await tester.tap(tracks.last);
      await tester.pump();
      expect(handler.playingSong!.id, 2);
      await tester.enterText(find.byType(TextField), 'The Band');
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Albums'));
      await tester.pump();
      expect(find.text('Blue Sky'), findsOneWidget);
      expect(find.text('Sunrise'), findsNothing);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Artists'));
      await tester.pump();
      expect(find.text('The Band'), findsNWidgets(2));
      expect(find.text('Blue Sky'), findsNothing);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Songs'));
      await tester.pump();
      expect(find.text('Sunrise'), findsNWidgets(2));
      library.songs = [];
      library.refresh();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
      expect(
        find.text('No matches found. Try a different search.'),
        findsOneWidget,
      );
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(find.text('Search your library to get started.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
