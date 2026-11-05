import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/data/repositories/artwork_repository.dart';
import 'package:player/data/repositories/music_library_repository.dart';
import 'package:player/data/services/artwork/deezer_artwork_service.dart';
import 'package:player/data/services/artwork/local_artwork_service.dart';
import 'package:player/ui/library/library_controller.dart';
import 'package:player/model/library_metadata.dart';

class FakeLibrary implements MusicLibraryRepository {
  final Completer<MusicLibrary> result = Completer();
  @override
  Future<MusicLibrary> load({
    required bool smartFilterEnabled,
    required int minimumDurationSeconds,
  }) => result.future;
}

class SequenceLibrary implements MusicLibraryRepository {
  int calls = 0;
  @override
  Future<MusicLibrary> load({
    required bool smartFilterEnabled,
    required int minimumDurationSeconds,
  }) async {
    calls++;
    return MusicLibrary(
      songs: [
        LibrarySong(
          model: SongMetadata(
            id: calls,
            data: '/$calls.mp3',
            title: 'Song',
            albumId: 2,
            artistId: 3,
            duration: 1000,
          ),
          playedTime: Duration.zero,
        ),
      ],
      albums: const [AlbumMetadata(id: 2, album: 'Album', artistId: 3)],
      artists: const [ArtistMetadata(id: 3, artist: 'Artist')],
    );
  }
}

class FakeCache implements ArtworkCache {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSearch implements ArtworkSearchService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeLocalArtwork extends LocalArtworkService {
  @override
  Future<Uint8List> loadAlbumArtwork(int id) async => Uint8List.fromList([1]);
}

void main() {
  test('refresh keeps previous model relationships stable and exposes read-only lists', () async {
    final controller = LibraryController(
      repository: SequenceLibrary(),
      artworkRepository: ArtworkRepository(
        cache: FakeCache(),
        search: FakeSearch(),
      ),
      localArtwork: FakeLocalArtwork(),
    );
    addTearDown(controller.dispose);
    await controller.load(smartFilterEnabled: false, minimumDurationSeconds: 0);
    final oldAlbum = controller.albumList.single;
    final oldSong = controller.songList.single;
    expect(() => controller.songList.clear(), throwsUnsupportedError);
    await controller.load(smartFilterEnabled: false, minimumDurationSeconds: 0);
    expect(controller.songList.single.id, 2);
    expect(oldAlbum.songList.single, same(oldSong));
  });
  test(
    'loads library state and connects songs to albums and artists',
    () async {
      final repository = FakeLibrary();
      final controller = LibraryController(
        repository: repository,
        artworkRepository: ArtworkRepository(
          cache: FakeCache(),
          search: FakeSearch(),
        ),
        localArtwork: FakeLocalArtwork(),
      );
      addTearDown(controller.dispose);
      final loading = controller.load(
        smartFilterEnabled: true,
        minimumDurationSeconds: 0,
      );
      repository.result.complete(
        const MusicLibrary(
          songs: [
            LibrarySong(
              model: SongMetadata(
                id: 4,
                data: '/4.mp3',
                title: 'Song',
                albumId: 2,
                artistId: 3,
                duration: 5000,
              ),
              playedTime: Duration(seconds: 7),
            ),
          ],
          albums: [AlbumMetadata(id: 2, album: 'Album', artistId: 3)],
          artists: [ArtistMetadata(id: 3, artist: 'Artist')],
        ),
      );
      expect(await loading, isTrue);
      expect(controller.isLoading, isFalse);
      expect(
        controller.songList.single.albumModel,
        same(controller.albumList.single),
      );
      expect(
        controller.songList.single.artistModel,
        same(controller.artistList.single),
      );
      expect(controller.songList.single.playedTime, const Duration(seconds: 7));
    },
  );
  test('exposes loading and error state when scanning fails', () async {
    final repository = FakeLibrary();
    final controller = LibraryController(
      repository: repository,
      artworkRepository: ArtworkRepository(
        cache: FakeCache(),
        search: FakeSearch(),
      ),
      localArtwork: LocalArtworkService(),
    );
    addTearDown(controller.dispose);
    final oldHandler = FlutterError.onError;
    FlutterError.onError = (_) {};
    addTearDown(() => FlutterError.onError = oldHandler);
    final loading = controller.load(
      smartFilterEnabled: false,
      minimumDurationSeconds: 0,
    );
    expect(controller.isLoading, isTrue);
    repository.result.completeError(StateError('scan failed'));
    expect(await loading, isFalse);
    expect(controller.isLoading, isFalse);
    expect(controller.error, isA<StateError>());
  });

  test('permission denial exposes an error rather than an empty library', () {
    final controller = LibraryController(
      repository: FakeLibrary(),
      artworkRepository: ArtworkRepository(
        cache: FakeCache(),
        search: FakeSearch(),
      ),
      localArtwork: LocalArtworkService(),
    );
    addTearDown(controller.dispose);
    controller.permissionDenied();
    expect(controller.error.toString(), contains('permission'));
  });
}
