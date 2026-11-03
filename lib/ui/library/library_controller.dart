import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:player/data/repositories/artwork_repository.dart';
import 'package:player/data/repositories/music_library_repository.dart';
import 'package:player/data/services/artwork/local_artwork_service.dart';
import 'package:player/data/services/music_library/music_library_service.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';
import 'package:player/model/song.dart';

class LibraryController extends ChangeNotifier {
  LibraryController({
    required this.repository,
    required this.artworkRepository,
    required this.localArtwork,
    List<SongData>? songs,
    List<AlbumData>? albums,
    List<ArtistData>? artists,
  }) : songList = songs ?? [],
       albumList = albums ?? [],
       artistList = artists ?? [];

  final MusicLibraryRepository repository;
  final ArtworkRepository artworkRepository;
  final LocalArtworkService localArtwork;
  final List<SongData> songList;
  final List<AlbumData> albumList;
  final List<ArtistData> artistList;
  bool isLoading = false;
  Object? error;
  bool isPermissionDenied = false;
  bool _disposed = false;
  int _generation = 0;

  void permissionDenied() {
    reportFailure(
      StateError('Music library permission was denied.'),
      permissionDenied: true,
    );
  }

  void reportFailure(Object failure, {bool permissionDenied = false}) {
    _generation++;
    isLoading = false;
    error = failure;
    isPermissionDenied = permissionDenied;
    notifyListeners();
  }

  Future<bool> load({
    required bool smartFilterEnabled,
    required int minimumDurationSeconds,
  }) async {
    final generation = ++_generation;
    isLoading = true;
    error = null;
    isPermissionDenied = false;
    notifyListeners();
    try {
      final library = await repository.load(
        smartFilterEnabled: smartFilterEnabled,
        minimumDurationSeconds: minimumDurationSeconds,
      );
      final artwork = await Future.wait(
        library.albums.map((album) => localArtwork.loadAlbumArtwork(album.id)),
      );
      if (_disposed || generation != _generation) return false;
      songList.clear();
      albumList.clear();
      artistList.clear();
      for (var i = 0; i < library.albums.length; i++) {
        final album = AlbumData(
          library.albums[i],
          artwork: artwork[i],
          songs: songList,
          artists: artistList,
        );
        albumList.add(album);
        unawaited(_loadAlbumUrl(album, generation));
      }
      final albumsById = {for (final album in albumList) album.id: album};
      for (final song in library.songs) {
        final album = albumsById[song.model.albumId];
        if (album != null) {
          songList.add(
            SongData(
              model: song.model,
              albumModel: album,
              playedTime: song.playedTime,
              artists: artistList,
            ),
          );
        }
      }
      for (final model in library.artists) {
        final artist = ArtistData(model, albums: albumList, songs: songList);
        artistList.add(artist);
        unawaited(_loadArtistUrl(artist, generation));
      }
      isLoading = false;
      notifyListeners();
      return true;
    } catch (exception, stack) {
      if (_disposed || generation != _generation) return false;
      error = exception;
      isPermissionDenied = exception is MusicPermissionDenied;
      isLoading = false;
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'music library',
        ),
      );
      notifyListeners();
      return false;
    }
  }

  Future<void> _loadAlbumUrl(AlbumData album, int generation) async {
    final url = await artworkRepository.albumUrl(album.id, album.name);
    if (_disposed || generation != _generation || !albumList.contains(album)) {
      return;
    }
    album.imageURL = url;
    if (url != null) notifyListeners();
  }

  Future<void> _loadArtistUrl(ArtistData artist, int generation) async {
    final url = await artworkRepository.artistUrl(artist.id, artist.name);
    if (_disposed ||
        generation != _generation ||
        !artistList.contains(artist)) {
      return;
    }
    artist.imageURL = url;
    if (url != null) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}
