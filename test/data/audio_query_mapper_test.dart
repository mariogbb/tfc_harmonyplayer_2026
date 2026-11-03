import 'package:flutter_test/flutter_test.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:player/data/services/music_library/audio_query_mapper.dart';

void main() {
  test('maps song identifiers, playback paths, and metadata', () {
    final result = mapSongMetadata(
      SongModel({
        '_id': 123,
        '_data': '/music/one.mp3',
        '_uri': 'content://media/audio/123',
        'title': 'One',
        'artist': 'Artist',
        'artist_id': 45,
        'album': 'Album',
        'album_id': 67,
        'duration': 42000,
        'track': 4,
      }),
    );

    expect(result.id, 123);
    expect(result.data, '/music/one.mp3');
    expect(result.uri, 'content://media/audio/123');
    expect(result.title, 'One');
    expect(result.artist, 'Artist');
    expect(result.artistId, 45);
    expect(result.album, 'Album');
    expect(result.albumId, 67);
    expect(result.duration, 42000);
    expect(result.track, 4);
  });

  test('preserves missing optional song metadata', () {
    final result = mapSongMetadata(
      SongModel({'_id': 1, '_data': '/music/unknown.mp3', 'title': 'Unknown'}),
    );
    expect(result.albumId, isNull);
    expect(result.artistId, isNull);
    expect(result.duration, isNull);
    expect(result.track, isNull);
  });
}
