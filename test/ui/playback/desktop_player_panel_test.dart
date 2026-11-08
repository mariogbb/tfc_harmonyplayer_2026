import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/control/media_control.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';
import 'package:player/model/library_metadata.dart';
import 'package:player/model/play_context.dart';
import 'package:player/model/song.dart';
import 'package:player/ui/playback/desktop_player_panel.dart';
import 'package:player/ui/playlists/playlist_controller.dart';
import 'package:provider/provider.dart';

import '../../control/player_handler_test.dart' show FakeBackend;
import '../playlists/playlist_tab_test.dart' show FakePlaylistRepository;

void main() {
  testWidgets('persistent player shows track and opens its album and artist', (
    tester,
  ) async {
    final bytes = await rootBundle.load('assets/no_artwork_icon.png');
    final artists = <ArtistData>[];
    final album = AlbumData(
      const AlbumMetadata(id: 7, album: 'Album'),
      artwork: Uint8List.sublistView(bytes),
      songs: [],
      artists: artists,
    );
    final song = SongData(
      model: const SongMetadata(
        id: 1,
        data: '/test',
        title: 'Track',
        artist: 'Artist',
      ),
      albumModel: album,
      playedTime: Duration.zero,
      artists: artists,
    );
    final backend = FakeBackend();
    final handler = PlayerHandler.withBackend(backend, (_, _) async {});
    final playlists = PlaylistController(FakePlaylistRepository());
    addTearDown(handler.dispose);
    addTearDown(playlists.dispose);
    handler.playSongList(
      PlayingContext('Test', ContextType.allSongs, [song]),
      0,
    );
    AlbumData? openedAlbum;
    ArtistData? openedArtist;
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: handler),
          ChangeNotifierProvider.value(value: playlists),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              width: 320,
              child: DesktopPlayerPanel(
                onAlbum: (value) => openedAlbum = value,
                onArtist: (value) => openedArtist = value,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Track'), findsOneWidget);
    await tester.tap(find.text('Track'));
    await tester.tap(find.text('Artist'));
    expect(openedAlbum, same(album));
    expect(openedArtist?.name, 'Artist');
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
    expect(handler.isPaused, isTrue);
    expect(tester.takeException(), isNull);
  });
}
