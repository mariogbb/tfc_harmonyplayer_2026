import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/data/data.dart';
import 'package:player/data/repositories/playlist_repository.dart';
import 'package:player/data/repositories/artwork_repository.dart';
import 'package:player/data/repositories/music_library_repository.dart';
import 'package:player/data/services/artwork/deezer_artwork_service.dart';
import 'package:player/data/services/artwork/local_artwork_service.dart';
import 'package:player/ui/library/library_controller.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/ui/library/albums/albums_tab.dart';
import 'package:player/ui/library/artists/artists_tab.dart';
import 'package:player/ui/library/songs/songs_tab.dart';
import 'package:player/ui/playlists/playlists_tab.dart';
import 'package:player/ui/playlists/playlist_controller.dart';
import 'package:provider/provider.dart';

class FakePlaylistRepository implements PlaylistRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeLibraryRepository implements MusicLibraryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeArtworkCache implements ArtworkCache {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeArtworkSearch implements ArtworkSearchService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final cases = <(Widget, String)>[
    (const PlayerSongsTab(), 'No song found'),
    (const PlayerAlbumTab(), 'No album found'),
    (const PlayerArtistTab(), 'No artist found'),
    (const PlaylistTab(), 'No playlist found'),
  ];

  for (final (tab, message) in cases) {
    testWidgets('$tab displays its empty state', (tester) async {
      final data = PlayerData.internal();
      addTearDown(data.dispose);
      final playlists = PlaylistController(FakePlaylistRepository());
      addTearDown(playlists.dispose);
      final library = LibraryController(
        repository: FakeLibraryRepository(),
        artworkRepository: ArtworkRepository(
          cache: FakeArtworkCache(),
          search: FakeArtworkSearch(),
        ),
        localArtwork: LocalArtworkService(),
      );
      addTearDown(library.dispose);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: data),
            ChangeNotifierProvider.value(value: playlists),
            ChangeNotifierProvider.value(value: library),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: tab),
          ),
        ),
      );
      expect(find.text(message), findsOneWidget);
    });
  }

  testWidgets('song tab shows a permission error instead of an empty state', (
    tester,
  ) async {
    final library = LibraryController(
      repository: FakeLibraryRepository(),
      artworkRepository: ArtworkRepository(
        cache: FakeArtworkCache(),
        search: FakeArtworkSearch(),
      ),
      localArtwork: LocalArtworkService(),
    );
    addTearDown(library.dispose);
    library.permissionDenied();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: library,
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: PlayerSongsTab()),
        ),
      ),
    );
    expect(
      find.text(
        'Music access was denied. Allow it in system settings, then reload.',
      ),
      findsOneWidget,
    );
    expect(find.text('No song found'), findsNothing);
  });
}
