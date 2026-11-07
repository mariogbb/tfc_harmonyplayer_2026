import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:player/app/library_refresh_coordinator.dart';
import 'package:player/data/repositories/artwork_repository.dart';
import 'package:player/data/repositories/music_library_repository.dart';
import 'package:player/data/repositories/playlist_repository.dart';
import 'package:player/data/services/artwork/deezer_artwork_service.dart';
import 'package:player/data/services/artwork/local_artwork_service.dart';
import 'package:player/model/playlist.dart';
import 'package:player/model/song.dart';
import 'package:player/ui/library/library_controller.dart';
import 'package:player/ui/playlists/playlist_controller.dart';

class FakeMusic implements MusicLibraryRepository {
  final requests = <Completer<MusicLibrary>>[];
  @override
  Future<MusicLibrary> load({
    required bool smartFilterEnabled,
    required int minimumDurationSeconds,
  }) {
    final request = Completer<MusicLibrary>();
    requests.add(request);
    return request.future;
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

class FakePlaylists implements PlaylistRepository {
  int loads = 0;
  @override
  Future<List<PlaylistData>> load(List<SongData> songs) async {
    loads++;
    return [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('failed refresh preserves playlists and a later successful refresh reloads them', () async {
    final music = FakeMusic();
    final library = LibraryController(
      repository: music,
      artworkRepository: ArtworkRepository(
        cache: FakeCache(),
        search: FakeSearch(),
      ),
      localArtwork: LocalArtworkService(),
    );
    final repository = FakePlaylists();
    final playlists = PlaylistController(
      repository,
      playlists: [PlaylistData(id: 9, name: 'Saved', songs: [])],
    );
    final coordinator = LibraryRefreshCoordinator(
      library: library,
      playlists: playlists,
      smartFilterEnabled: () => true,
      minimumDurationSeconds: () => 0,
    );
    final previous = FlutterError.onError;
    FlutterError.onError = (_) {};
    addTearDown(() {
      FlutterError.onError = previous;
      coordinator.dispose();
      playlists.dispose();
      library.dispose();
    });
    final first = coordinator.refresh();
    music.requests[0].completeError(StateError('scan failed'));
    await first;
    expect(library.error, isNotNull);
    expect(playlists.playlists.single.name, 'Saved');
    expect(repository.loads, 0);
    final second = coordinator.refresh();
    music.requests[1].complete(
      const MusicLibrary(songs: [], albums: [], artists: []),
    );
    await second;
    expect(library.error, isNull);
    expect(repository.loads, 1);
  });
  test('only the latest successful refresh reloads playlists', () async {
    final music = FakeMusic();
    final library = LibraryController(
      repository: music,
      artworkRepository: ArtworkRepository(
        cache: FakeCache(),
        search: FakeSearch(),
      ),
      localArtwork: LocalArtworkService(),
    );
    final repository = FakePlaylists();
    final playlists = PlaylistController(repository);
    final coordinator = LibraryRefreshCoordinator(
      library: library,
      playlists: playlists,
      smartFilterEnabled: () => true,
      minimumDurationSeconds: () => 0,
    );
    addTearDown(() {
      coordinator.dispose();
      playlists.dispose();
      library.dispose();
    });
    final first = coordinator.refresh();
    final second = coordinator.refresh();
    const empty = MusicLibrary(songs: [], albums: [], artists: []);
    music.requests[1].complete(empty);
    await second;
    music.requests[0].complete(empty);
    await first;
    expect(repository.loads, 1);
  });
}
