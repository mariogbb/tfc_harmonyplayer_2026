import 'package:player/data/linux_music.dart';
import 'package:player/data/services/music_library/music_library_service.dart';
import 'package:player/model/library_metadata.dart';

class DesktopMusicLibraryService implements MusicLibraryService {
  DesktopMusicLibraryService({LinuxMusicLibrary? library})
    : _library = library ?? LinuxMusicLibrary();

  final LinuxMusicLibrary _library;

  @override
  Future<MusicLibrarySnapshot> scan() async {
    final directory = await _library.musicDirectory();
    final songs = directory == null
        ? <SongMetadata>[]
        : await _library.scan(directory);
    final albums = <int, AlbumMetadata>{};
    final artists = <int, ArtistMetadata>{};

    for (final song in songs) {
      artists.putIfAbsent(
        song.artistId!,
        () => ArtistMetadata(id: song.artistId!, artist: song.artist!),
      );
      albums.putIfAbsent(
        song.albumId!,
        () => AlbumMetadata(
          id: song.albumId!,
          album: song.album!,
          artist: song.artist,
          artistId: song.artistId,
        ),
      );
    }

    return MusicLibrarySnapshot(
      songs: songs,
      albums: albums.values.toList(),
      artists: artists.values.toList(),
    );
  }
}
