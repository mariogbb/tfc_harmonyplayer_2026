import 'package:player/model/library_metadata.dart';
import 'package:player/data/services/music_library/music_library_service.dart';

typedef SongPlayedTimeLoader = Future<Duration> Function(int songId);

class LibrarySong {
  const LibrarySong({required this.model, required this.playedTime});

  final SongMetadata model;
  final Duration playedTime;
}

/// A prepared library, independent of the legacy models' global state.
class MusicLibrary {
  const MusicLibrary({
    required this.songs,
    required this.albums,
    required this.artists,
  });

  final List<LibrarySong> songs;
  final List<AlbumMetadata> albums;
  final List<ArtistMetadata> artists;
}

abstract class MusicLibraryRepository {
  Future<MusicLibrary> load({
    required bool smartFilterEnabled,
    required int minimumDurationSeconds,
  });
}

class DefaultMusicLibraryRepository implements MusicLibraryRepository {
  DefaultMusicLibraryRepository({
    required this.service,
    required this.loadPlayedTime,
  });

  final MusicLibraryService service;
  final SongPlayedTimeLoader loadPlayedTime;

  @override
  Future<MusicLibrary> load({
    required bool smartFilterEnabled,
    required int minimumDurationSeconds,
  }) async {
    final snapshot = await service.scan();
    final availableAlbums = {for (final album in snapshot.albums) album.id};
    final songs = <LibrarySong>[];
    for (final song in filterLibrarySongs(
      snapshot.songs,
      smartFilterEnabled: smartFilterEnabled,
      minimumDurationSeconds: minimumDurationSeconds,
    )) {
      if (!availableAlbums.contains(song.albumId)) continue;
      songs.add(
        LibrarySong(model: song, playedTime: await loadPlayedTime(song.id)),
      );
    }

    final albumIds = songs.map((song) => song.model.albumId).toSet();
    final albums = snapshot.albums
        .where((album) => albumIds.contains(album.id))
        .toList();
    final artistIds = albums.map((album) => album.artistId).toSet();
    final artists = snapshot.artists
        .where((artist) => artistIds.contains(artist.id))
        .toList();
    return MusicLibrary(songs: songs, albums: albums, artists: artists);
  }
}
