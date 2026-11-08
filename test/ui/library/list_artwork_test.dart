import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:player/model/library_metadata.dart';
import 'package:player/model/song.dart';
import 'package:player/ui/library/albums/album_list_item.dart';
import 'package:player/ui/library/library_controller.dart';
import 'package:player/ui/library/songs/song_list_item.dart';
import 'package:provider/provider.dart';

import '../../control/player_handler_test.dart' show FakeBackend;
import '../../data/player_settings_test.dart' show FakeSettingsStore;
import 'library_tabs_test.dart'
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
  void artworkUpdated() => notifyListeners();
}

void main() {
  testWidgets('album and song rows update when online artwork arrives', (
    tester,
  ) async {
    final library = _Library();
    final settings = PlayerSettings(FakeSettingsStore());
    final handler = PlayerHandler.withBackend(FakeBackend(), (_, _) async {});
    PlayerData.instance.handler = handler;
    addTearDown(library.dispose);
    addTearDown(settings.dispose);
    addTearDown(handler.dispose);
    final album = AlbumData(
      const AlbumMetadata(id: 4, album: 'Album', artist: 'Artist'),
      artwork: fallbackArtwork,
      songs: [],
      artists: [],
    );
    final song = SongData(
      model: const SongMetadata(id: 1, data: '/song', title: 'Song'),
      albumModel: album,
      playedTime: Duration.zero,
      artists: [],
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LibraryController>.value(value: library),
          ChangeNotifierProvider.value(value: settings),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Column(
              children: [
                AlbumListItem(data: album),
                SongListItem(data: song, play: (_) {}),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.byType(CachedNetworkImage), findsNothing);
    album.imageURL = 'https://example.com/cover.jpg';
    library.artworkUpdated();
    await tester.pump();
    final images = tester
        .widgetList<CachedNetworkImage>(find.byType(CachedNetworkImage))
        .toList();
    expect(images, hasLength(2));
    expect(images.every((image) => image.imageUrl == album.imageURL), isTrue);
    final context = tester.element(find.byType(AlbumListItem));
    expect(images.first.placeholder!(context, album.imageURL!), isA<Image>());
    expect(
      images.first.errorWidget!(context, album.imageURL!, Exception()),
      isA<Image>(),
    );
  });
}
