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
    final albumsById = {for (final album in snapshot.albums) album.id: album};
    final artistsById = {
      for (final artist in snapshot.artists) artist.id: artist,
    };
    var unknownAlbumId = -2147483648;
    while (albumsById.containsKey(unknownAlbumId)) {
      unknownAlbumId++;
    }
    var unknownArtistId = -2147483648;
    while (artistsById.containsKey(unknownArtistId)) {
      unknownArtistId++;
    }
    final usedAlbums = <int, AlbumMetadata>{};
    final usedArtists = <int, ArtistMetadata>{};
    final songs = <LibrarySong>[];
    for (final song in filterLibrarySongs(
      snapshot.songs,
      smartFilterEnabled: smartFilterEnabled,
      minimumDurationSeconds: minimumDurationSeconds,
    )) {
      final sourceAlbum = albumsById[song.albumId];
      final sourceArtist =
          artistsById[song.artistId] ?? artistsById[sourceAlbum?.artistId];
      final artist =
          sourceArtist ??
          ArtistMetadata(id: unknownArtistId, artist: 'Unknown artist');
      final albumId = sourceAlbum?.id ?? unknownAlbumId;
      final album = usedAlbums.putIfAbsent(
        albumId,
        () => AlbumMetadata(
          id: albumId,
          album: sourceAlbum?.album ?? 'Unknown album',
          artist: sourceAlbum?.artist ?? artist.artist,
          artistId: artistsById.containsKey(sourceAlbum?.artistId)
              ? sourceAlbum!.artistId
              : artist.id,
        ),
      );
      usedArtists[artist.id] = artist;
      final albumArtist = artistsById[album.artistId];
      if (albumArtist != null) usedArtists[albumArtist.id] = albumArtist;
      final normalized = SongMetadata(
        id: song.id,
        data: song.data,
        title: song.title,
        uri: song.uri,
        artist: song.artist ?? artist.artist,
        artistId: artist.id,
        album: song.album ?? album.album,
        albumId: album.id,
        duration: song.duration,
        track: song.track,
      );
      songs.add(
        LibrarySong(
          model: normalized,
          playedTime: await loadPlayedTime(song.id),
        ),
      );
    }

    return MusicLibrary(
      songs: songs,
      albums: usedAlbums.values.toList(),
      artists: usedArtists.values.toList(),
    );
  }
}
