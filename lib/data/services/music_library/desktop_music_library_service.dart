import 'package:on_audio_query/on_audio_query.dart';
import 'package:player/data/linux_music.dart';
import 'package:player/data/services/music_library/music_library_service.dart';

class DesktopMusicLibraryService implements MusicLibraryService {
  DesktopMusicLibraryService({LinuxMusicLibrary? library})
    : _library = library ?? LinuxMusicLibrary();

  final LinuxMusicLibrary _library;

  @override
  Future<MusicLibrarySnapshot> scan() async {
    final directory = await _library.musicDirectory();
    final songs = directory == null
        ? <SongModel>[]
        : await _library.scan(directory);
    final albums = <int, AlbumModel>{};
    final artists = <int, ArtistModel>{};

    for (final song in songs) {
      artists.putIfAbsent(
        song.artistId!,
        () => ArtistModel({'_id': song.artistId, 'artist': song.artist}),
      );
      albums.putIfAbsent(
        song.albumId!,
        () => AlbumModel({
          '_id': song.albumId,
          'album': song.album,
          'artist': song.artist,
          'artist_id': song.artistId,
          'numsongs': 0,
        }),
      );
    }

    return MusicLibrarySnapshot(
      songs: songs,
      albums: albums.values.toList(),
      artists: artists.values.toList(),
    );
  }
}
