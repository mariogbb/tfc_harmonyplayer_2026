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
import 'package:player/ui/playback/control_tab.dart';
import 'package:player/ui/playlists/playlist_controller.dart';
import 'package:provider/provider.dart';

import '../../control/player_handler_test.dart' show FakeBackend;
import '../playlists/playlist_tab_test.dart' show FakePlaylistRepository;

void main() {
  for (final size in [const Size(1200, 800), const Size(390, 844)]) {
    testWidgets('player opens, shows controls and closes at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final bytes = await rootBundle.load('assets/no_artwork_icon.png');
      final artists = <ArtistData>[];
      final album = AlbumData(
        const AlbumMetadata(id: 1, album: 'Album'),
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
          duration: 5000,
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
      final events = <bool>[];
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
            home: Scaffold(
              bottomSheet: PlayerControlTab(
                handler: handler,
                onEvent: events.add,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Track'));
      await tester.pumpAndSettle();
      expect(events, contains(true));
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
      expect(find.byIcon(Icons.skip_next), findsOneWidget);
      expect(find.byIcon(Icons.skip_previous), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
      await tester.pumpAndSettle();
      expect(events.last, isFalse);
      expect(find.text('Track'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
