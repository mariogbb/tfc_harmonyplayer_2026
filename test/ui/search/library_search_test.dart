import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';
import 'package:player/model/library_metadata.dart';
import 'package:player/model/song.dart';
import 'package:player/ui/search/library_search.dart';

void main() {
  test('matches metadata without multiplying duplicate track names', () async {
    final artists = <ArtistData>[];
    final album = AlbumData(
      const AlbumMetadata(id: 1, album: 'Blue Sky', artist: 'The Band'),
      artwork: Uint8List(0),
      songs: [],
      artists: artists,
    );
    SongData song(int id) => SongData(
      model: SongMetadata(
        id: id,
        data: '/$id',
        title: 'Sunrise',
        artist: 'The Band',
        album: 'Blue Sky',
      ),
      albumModel: album,
      playedTime: Duration.zero,
      artists: artists,
    );
    final songs = [song(1), song(2)];
    final artist = ArtistData(
      const ArtistMetadata(id: 1, artist: 'The Band'),
      albums: [album],
      songs: songs,
    );
    final results = await searchLibrary(
      query: 'SUNRISE',
      songs: songs,
      albums: [album],
      artists: [artist],
    );
    expect(results.songs.map((item) => item.id), [1, 2]);
    final byArtist = await searchLibrary(
      query: 'The Band',
      songs: songs,
      albums: [album],
      artists: [artist],
    );
    expect(byArtist.songs.map((item) => item.id), [1, 2]);
    expect(byArtist.albums, [album]);
    expect(byArtist.artists, [artist]);
    final blank = await searchLibrary(
      query: '  ',
      songs: songs,
      albums: [album],
      artists: [artist],
    );
    expect(blank.songs, isEmpty);
  });
}
