import 'dart:developer' as developer;

import 'package:player/data/services/artwork/deezer_artwork_service.dart';

abstract class ArtworkCache {
  Future<String?> loadAlbum(int id);
  Future<String?> loadArtist(int id);
  Future<void> saveAlbum(int id, String url);
  Future<void> saveArtist(int id, String url);
}

class ArtworkRepository {
  ArtworkRepository({required this.cache, required this.search});

  final ArtworkCache cache;
  final ArtworkSearchService search;

  Future<String?> albumUrl(int id, String name) => _load(
    read: () => cache.loadAlbum(id),
    searchRemote: () => search.findAlbumArtwork(name),
    write: (url) => cache.saveAlbum(id, url),
  );

  Future<String?> artistUrl(int id, String name) => _load(
    read: () => cache.loadArtist(id),
    searchRemote: () => search.findArtistArtwork(name),
    write: (url) => cache.saveArtist(id, url),
  );

  Future<String?> _load({
    required Future<String?> Function() read,
    required Future<String?> Function() searchRemote,
    required Future<void> Function(String) write,
  }) async {
    String? cached;
    try {
      cached = await read();
    } catch (error, stack) {
      developer.log(
        'Artwork cache read failed; trying the network.',
        name: 'artwork',
        error: error,
        stackTrace: stack,
      );
    }
    if (cached != null) return cached;
    try {
      final url = await searchRemote();
      if (url != null) {
        try {
          await write(url);
        } catch (error, stack) {
          developer.log(
            'Artwork cache write failed.',
            name: 'artwork',
            error: error,
            stackTrace: stack,
          );
        }
      }
      return url;
    } catch (error, stack) {
      developer.log(
        'Online artwork lookup failed.',
        name: 'artwork',
        error: error,
        stackTrace: stack,
      );
      return null;
    }
  }
}
