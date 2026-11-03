import 'package:firebase_performance/firebase_performance.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:player/data/services/music_library/audio_query_mapper.dart';
import 'package:player/data/services/music_library/music_library_service.dart';

/// Media-library discovery for the existing non-desktop platform path.
class PlatformMusicLibraryService implements MusicLibraryService {
  @override
  Future<MusicLibrarySnapshot> scan() async {
    if (await Permission.storage.isDenied) {
      return const MusicLibrarySnapshot(songs: [], albums: [], artists: []);
    }

    final trace = FirebasePerformance.instance.newTrace('song-load');
    await trace.start();

    try {
      final query = OnAudioQuery();
      final albums = await query.queryAlbums();
      final songs = await query.querySongs();

      trace.setMetric('song_number', songs.length);

      final artists = await query.queryArtists();

      return MusicLibrarySnapshot(
        songs: songs.map(mapSongMetadata).toList(),
        albums: albums.map(mapAlbumMetadata).toList(),
        artists: artists.map(mapArtistMetadata).toList(),
      );
    } finally {
      await trace.stop();
    }
  }
}
