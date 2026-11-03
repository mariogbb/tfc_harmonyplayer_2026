import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:player/data/data.dart';
import 'package:player/data/linux_music.dart';
import 'package:player/data/repositories/music_library_repository.dart';
import 'package:player/data/repositories/artwork_repository.dart';
import 'package:player/data/services/artwork/deezer_artwork_service.dart';
import 'package:player/data/services/artwork/local_artwork_service.dart';
import 'package:player/data/services/music_library/audio_query_mapper.dart';
import 'package:player/model/library_metadata.dart';
import 'package:player/data/services/music_library/desktop_music_library_service.dart';
import 'package:player/data/services/music_library/music_library_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeMusicLibrary implements MusicLibraryService {
  var scans = 0;

  @override
  Future<MusicLibrarySnapshot> scan() async {
    scans++;
    return const MusicLibrarySnapshot(songs: [], albums: [], artists: []);
  }
}

class UnusedArtworkCache implements ArtworkCache {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class UnusedArtworkSearch implements ArtworkSearchService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeDesktopScanner extends LinuxMusicLibrary {
  @override
  Future<String?> musicDirectory() async => '/music';

  @override
  Future<List<SongMetadata>> scan(String directory) async {
    expect(directory, '/music');

    return [
      const SongMetadata(
        id: 1,
        data: '/music/song.mp3',
        title: 'Song',
        artist: 'Artist',
        artistId: 2,
        album: 'Album',
        albumId: 3,
        duration: 1000,
      ),
      const SongMetadata(
        id: 4,
        data: '/music/other.mp3',
        title: 'Other',
        artist: 'Artist',
        artistId: 2,
        album: 'Album',
        albumId: 3,
        duration: 2000,
      ),
    ];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'PlayerData loads an injected library without platform plugins',
    () async {
      SharedPreferences.setMockInitialValues({});
      await Settings.init();

      final library = FakeMusicLibrary();
      final data = PlayerData.internal()
        ..configureMusicLibrary(
          DefaultMusicLibraryRepository(
            service: library,
            loadPlayedTime: (_) async => Duration.zero,
          ),
        )
        ..configureArtwork(
          ArtworkRepository(
            cache: UnusedArtworkCache(),
            search: UnusedArtworkSearch(),
          ),
          LocalArtworkService(),
        );

      addTearDown(data.dispose);

      await data.loadSongs();

      expect(library.scans, 1);
      expect(data.songList, isEmpty);
      expect(data.albumList, isEmpty);
      expect(data.artistList, isEmpty);
    },
  );

  test('song filtering retains the existing title and duration rules', () {
    SongMetadata song(int id, String title, int? duration) => mapSongMetadata(
      SongModel({
        '_id': id,
        '_data': '/music/$id.mp3',
        'title': title,
        'duration': duration,
      }),
    );

    final songs = [
      song(1, 'AUD recording', 3000),
      song(2, 'Short', 999),
      song(3, 'Long enough', 1000),
      song(4, 'Unknown duration', null),
    ];

    expect(
      filterLibrarySongs(
        songs,
        smartFilterEnabled: true,
        minimumDurationSeconds: 1,
      ).map((song) => song.id),
      [3],
    );

    expect(
      filterLibrarySongs(
        songs,
        smartFilterEnabled: false,
        minimumDurationSeconds: 1,
      ).map((song) => song.id),
      [1, 3],
    );
  });

  test('desktop adapter groups songs using their existing IDs', () async {
    final service = DesktopMusicLibraryService(library: FakeDesktopScanner());
    final snapshot = await service.scan();

    expect(snapshot.songs.map((song) => song.id), [1, 4]);
    expect(snapshot.albums.map((album) => album.id), [3]);
    expect(snapshot.artists.map((artist) => artist.id), [2]);
  });
}
