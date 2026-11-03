import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';
import 'package:player/model/song.dart';
import 'package:player/model/library_metadata.dart';

void main() {
  test('library models use injected lists for relationships and totals', () {
    final songs = <SongData>[];
    final albums = <AlbumData>[];
    final artists = <ArtistData>[];
    final album = AlbumData(
      const AlbumMetadata(id: 1, album: 'Album', artistId: 2),
      artwork: Uint8List.fromList([1, 2]),
      songs: songs,
      artists: artists,
    );
    final artist = ArtistData(
      const ArtistMetadata(id: 2, artist: 'Artist'),
      albums: albums,
      songs: songs,
    );
    final song = SongData(
      model: const SongMetadata(
        id: 3,
        data: '/music/song.mp3',
        title: 'Song',
        artistId: 2,
        albumId: 1,
        duration: 2500,
        track: 1,
      ),
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
      const ArtistMetadata(id: 2, artist: 'Artist'),
      albums: albums,
      songs: songs,
    );
    final album = AlbumData(
      const AlbumMetadata(id: 1, album: 'Unknown'),
      artwork: Uint8List(0),
      songs: songs,
      artists: artists,
    );
    albums.add(album);
    songs.add(
      SongData(
        model: const SongMetadata(
          id: 3,
          data: '/music/song.mp3',
          title: 'Song',
        ),
        albumModel: album,
        playedTime: Duration.zero,
        artists: artists,
      ),
    );

    expect(artist.albumList, isEmpty);
    expect(artist.songList, isEmpty);
  });
}
