import 'package:on_audio_query/on_audio_query.dart';

/// Raw platform library data. App-owned models can replace these plugin models
/// once the rest of the library has been migrated.
class MusicLibrarySnapshot {
  const MusicLibrarySnapshot({
    required this.songs,
    required this.albums,
    required this.artists,
    this.filterEntitiesBeforeLoading = false,
  });

  final List<SongModel> songs;
  final List<AlbumModel> albums;
  final List<ArtistModel> artists;

  /// Desktop synthesizes entities from songs, so do not load filtered entities.
  final bool filterEntitiesBeforeLoading;
}

abstract class MusicLibraryService {
  Future<MusicLibrarySnapshot> scan();
}

List<SongModel> filterLibrarySongs(
  List<SongModel> songs, {
  required bool smartFilterEnabled,
  required int minimumDurationSeconds,
}) {
  return songs.where((song) {
    if (smartFilterEnabled && song.title.startsWith('AUD')) return false;
    final duration = song.duration;
    return duration != null && duration >= minimumDurationSeconds * 1000;
  }).toList();
}
