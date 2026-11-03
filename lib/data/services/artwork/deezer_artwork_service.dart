import 'dart:convert';

import 'package:http/http.dart' as http;

abstract class ArtworkSearchService {
  Future<String?> findAlbumArtwork(String name);
  Future<String?> findArtistArtwork(String name);
}

class DeezerArtworkService implements ArtworkSearchService {
  DeezerArtworkService(this.client);

  final http.Client client;

  @override
  Future<String?> findAlbumArtwork(String name) =>
      _findArtwork('album', 'cover_xl', name);

  @override
  Future<String?> findArtistArtwork(String name) =>
      _findArtwork('artist', 'picture_xl', name);

  Future<String?> _findArtwork(String type, String field, String name) async {
    final uri = Uri.https('api.deezer.com', '/search/$type', {'q': name});
    final response = await client.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) return null;

    final json = jsonDecode(response.body);

    if (json is! Map || json['data'] is! List) return null;

    final data = json['data'] as List;

    if (data.isEmpty || data.first is! Map) return null;

    final url = (data.first as Map)[field];

    return url is String && url.isNotEmpty ? url : null;
  }
}
