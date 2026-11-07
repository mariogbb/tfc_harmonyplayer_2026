import 'package:player/model/library_metadata.dart';

/// Platform-independent library metadata from a discovery service.
class MusicLibrarySnapshot {
  const MusicLibrarySnapshot({
    required this.songs,
    required this.albums,
    required this.artists,
  });

  final List<SongMetadata> songs;
  final List<AlbumMetadata> albums;
  final List<ArtistMetadata> artists;
}

abstract class MusicLibraryService {
  Future<MusicLibrarySnapshot> scan();
}

class MusicPermissionDenied implements Exception {
  const MusicPermissionDenied();
}

List<SongMetadata> filterLibrarySongs(
  List<SongMetadata> songs, {
  required bool smartFilterEnabled,
  required int minimumDurationSeconds,
}) {
  return songs.where((song) {
    if (smartFilterEnabled && song.title.startsWith('AUD')) return false;
    final duration = song.duration;
    return duration == null || duration >= minimumDurationSeconds * 1000;
  }).toList();
}
