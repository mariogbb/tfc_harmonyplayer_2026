/// Platform-independent metadata used by the library and playback layers.
class SongMetadata {
  const SongMetadata({
    required this.id,
    required this.data,
    required this.title,
    this.uri,
    this.artist,
    this.artistId,
    this.album,
    this.albumId,
    this.duration,
    this.track,
  });

  final int id;
  final String data;
  final String title;
  final String? uri;
  final String? artist;
  final int? artistId;
  final String? album;
  final int? albumId;
  final int? duration;
  final int? track;
}

class AlbumMetadata {
  const AlbumMetadata({
    required this.id,
    required this.album,
    this.artist,
    this.artistId,
  });

  final int id;
  final String album;
  final String? artist;
  final int? artistId;
}

class ArtistMetadata {
  const ArtistMetadata({required this.id, required this.artist});

  final int id;
  final String artist;
}
