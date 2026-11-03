import 'package:flutter_test/flutter_test.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:player/data/repositories/music_library_repository.dart';
import 'package:player/data/services/music_library/music_library_service.dart';

class FakeService implements MusicLibraryService {
  FakeService(this.snapshot);
  final MusicLibrarySnapshot snapshot;

  @override
  Future<MusicLibrarySnapshot> scan() async => snapshot;
}

void main() {
  SongModel song(int id, int? albumId, String title, int? duration) =>
      SongModel({
        '_id': id,
        '_data': '/music/$id.mp3',
        'title': title,
        'album_id': albumId,
        'duration': duration,
      });
  AlbumModel album(int id, int artistId) => AlbumModel({
    '_id': id,
    'album': 'Album $id',
    'artist_id': artistId,
    'numsongs': 1,
  });
  ArtistModel artist(int id) =>
      ArtistModel({'_id': id, 'artist': 'Artist $id'});

  test(
    'filters songs, groups albums and artists, and restores history',
    () async {
      final historyRequests = <int>[];
      final repository = DefaultMusicLibraryRepository(
        service: FakeService(
          MusicLibrarySnapshot(
            songs: [
              song(10, 1, 'Song', 5000),
              song(11, 1, 'Another', 6000),
              song(12, 2, 'AUD recording', 5000),
              song(13, 2, 'Too short', 500),
              song(14, 99, 'Missing album', 5000),
              song(15, null, 'No album', 5000),
              song(16, 1, 'No duration', null),
            ],
            albums: [album(1, 3), album(2, 4)],
            artists: [artist(3), artist(4)],
          ),
        ),
        loadPlayedTime: (id) async {
          historyRequests.add(id);
          return Duration(seconds: id);
        },
      );

      final library = await repository.load(
        smartFilterEnabled: true,
        minimumDurationSeconds: 1,
      );

      expect(library.songs.map((song) => song.model.id), [10, 11]);
      expect(library.songs.map((song) => song.playedTime), [
        const Duration(seconds: 10),
        const Duration(seconds: 11),
      ]);
      expect(library.albums.map((album) => album.id), [1]);
      expect(library.artists.map((artist) => artist.id), [3]);
      expect(historyRequests, [10, 11]);
    },
  );

  test('keeps a playable song when its artist is missing', () async {
    final repository = DefaultMusicLibraryRepository(
      service: FakeService(
        MusicLibrarySnapshot(
          songs: [song(42, 5, 'Song', 1000)],
          albums: [album(5, 7)],
          artists: [],
        ),
      ),
      loadPlayedTime: (_) async => Duration.zero,
    );

    final library = await repository.load(
      smartFilterEnabled: false,
      minimumDurationSeconds: 0,
    );

    expect(library.songs.single.model.id, 42);
    expect(library.albums.single.id, 5);
    expect(library.artists, isEmpty);
    expect(library.songs.single.playedTime, Duration.zero);
  });
}
