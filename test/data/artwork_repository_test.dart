import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:player/data/repositories/artwork_repository.dart';
import 'package:player/data/services/artwork/deezer_artwork_service.dart';

class FakeCache implements ArtworkCache {
  final albums = <int, String>{};
  final artists = <int, String>{};

  @override
  Future<String?> loadAlbum(int id) async => albums[id];
  @override
  Future<String?> loadArtist(int id) async => artists[id];
  @override
  Future<void> saveAlbum(int id, String url) async => albums[id] = url;
  @override
  Future<void> saveArtist(int id, String url) async => artists[id] = url;
}

class FakeSearch implements ArtworkSearchService {
  int calls = 0;
  bool fail = false;
  @override
  Future<String?> findAlbumArtwork(String name) async {
    calls++;
    if (fail) throw Exception('network failure');
    return 'https://example.com/album';
  }

  @override
  Future<String?> findArtistArtwork(String name) async {
    calls++;
    if (fail) throw Exception('network failure');
    return 'https://example.com/artist';
  }
}

void main() {
  test('uses cached URLs without searching', () async {
    final cache = FakeCache()..albums[1] = 'cached';
    final search = FakeSearch();
    final repository = ArtworkRepository(cache: cache, search: search);

    expect(await repository.albumUrl(1, 'Album'), 'cached');
    expect(search.calls, 0);
  });

  test('searches and caches album and artist URLs', () async {
    final cache = FakeCache();
    final search = FakeSearch();
    final repository = ArtworkRepository(cache: cache, search: search);

    expect(await repository.albumUrl(1, 'Album'), 'https://example.com/album');
    expect(
      await repository.artistUrl(2, 'Artist'),
      'https://example.com/artist',
    );
    expect(cache.albums[1], 'https://example.com/album');
    expect(cache.artists[2], 'https://example.com/artist');
    expect(search.calls, 2);
  });

  test('returns no URL on network failure', () async {
    final search = FakeSearch()..fail = true;
    final repository = ArtworkRepository(cache: FakeCache(), search: search);
    expect(await repository.artistUrl(1, 'Artist'), isNull);
  });

  test('Deezer requests encode names and parse responses', () async {
    final client = MockClient((request) async {
      expect(request.url.host, 'api.deezer.com');
      expect(request.url.path, '/search/album');
      expect(request.url.queryParameters, {'q': 'A & B #1'});
      return http.Response(
        '{"data":[{"cover_xl":"https://example.com/a"}]}',
        200,
      );
    });
    addTearDown(client.close);
    expect(
      await DeezerArtworkService(client).findAlbumArtwork('A & B #1'),
      'https://example.com/a',
    );
  });
}
