import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';
import 'package:player/model/song.dart';

void main() {
  test('library models use injected lists for relationships and totals', () {
    final songs = <SongData>[];
    final albums = <AlbumData>[];
    final artists = <ArtistData>[];
    final album = AlbumData(
      AlbumModel({'_id': 1, 'album': 'Album', 'artist_id': 2, 'numsongs': 1}),
      artwork: Uint8List.fromList([1, 2]),
      songs: songs,
      artists: artists,
    );
    final artist = ArtistData(
      ArtistModel({'_id': 2, 'artist': 'Artist'}),
      albums: albums,
      songs: songs,
    );
    final song = SongData(
      model: SongModel({
        '_id': 3,
        '_data': '/music/song.mp3',
        'title': 'Song',
        'artist_id': 2,
        'album_id': 1,
        'duration': 2500,
        'track': 1,
      }),
      albumModel: album,
      playedTime: const Duration(seconds: 5),
      artists: artists,
    );

    albums.add(album);
    artists.add(artist);
    songs.add(song);

    expect(album.songList, [song]);
    expect(album.artistData, same(artist));
    expect(album.duration, const Duration(milliseconds: 2500));
    expect(album.playedTime, const Duration(seconds: 5));
    expect(artist.albumList, [album]);
    expect(artist.songList, [song]);
    expect(artist.duration, const Duration(milliseconds: 2500));
    expect(song.artistModel, same(artist));
    expect(song.artwork, [1, 2]);

    songs.clear();
    expect(album.songList, isEmpty);
    expect(artist.duration, Duration.zero);
  });

  test('artist relationships ignore missing artist IDs', () {
    final albums = <AlbumData>[];
    final songs = <SongData>[];
    final artists = <ArtistData>[];
    final artist = ArtistData(
      ArtistModel({'_id': 2, 'artist': 'Artist'}),
      albums: albums,
      songs: songs,
    );
    final album = AlbumData(
      AlbumModel({'_id': 1, 'album': 'Unknown', 'numsongs': 1}),
      artwork: Uint8List(0),
      songs: songs,
      artists: artists,
    );
    albums.add(album);
    songs.add(
      SongData(
        model: SongModel({
          '_id': 3,
          '_data': '/music/song.mp3',
          'title': 'Song',
        }),
        albumModel: album,
        playedTime: Duration.zero,
        artists: artists,
      ),
    );

    expect(artist.albumList, isEmpty);
    expect(artist.songList, isEmpty);
  });
}
