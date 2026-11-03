import 'package:flutter/foundation.dart';
import 'package:player/data/repositories/playlist_repository.dart';
import 'package:player/model/playlist.dart';
import 'package:player/model/song.dart';

/// Playlist presentation state backed by a repository.
class PlaylistController extends ChangeNotifier {
  PlaylistController(this.repository, {List<PlaylistData>? playlists})
    : playlists = playlists ?? [];

  final PlaylistRepository repository;
  final List<PlaylistData> playlists;
  bool _disposed = false;
  Object? error;
  bool isLoading = false;

  Future<T?> _perform<T>(Future<T> Function() operation) async {
    try {
      error = null;
      return await operation();
    } catch (exception, stack) {
      error = exception;
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'playlists',
        ),
      );
      if (!_disposed) notifyListeners();
      return null;
    }
  }

  Future<void> load(List<SongData> songs) async {
    isLoading = true;
    notifyListeners();
    final loaded = await _perform(() => repository.load(songs));
    if (_disposed) return;
    isLoading = false;
    if (loaded == null) {
      notifyListeners();
      return;
    }
    playlists
      ..clear()
      ..addAll(loaded);
    notifyListeners();
  }

  Future<PlaylistData?> create(String name) async {
    if (playlists.any((playlist) => playlist.name == name)) return null;
    final playlist = await _perform(() => repository.create(name));
    if (_disposed) return playlist;
    if (playlist != null) playlists.add(playlist);
    notifyListeners();
    return playlist;
  }

  Future<void> addSong(PlaylistData playlist, SongData song) async {
    if (playlist.songs.contains(song)) return;
    final success = await _perform(() async {
      await repository.addSong(playlist.id, song.id);
      return true;
    });
    if (success != true) return;
    if (_disposed) return;
    if (!playlist.songs.contains(song)) playlist.songs.add(song);
    notifyListeners();
  }

  Future<void> removeSong(PlaylistData playlist, SongData song) async {
    if (!playlist.songs.contains(song)) return;
    final success = await _perform(() async {
      await repository.removeSong(playlist.id, song.id);
      return true;
    });
    if (success != true) return;
    if (_disposed) return;
    playlist.songs.remove(song);
    notifyListeners();
  }

  Future<void> rename(String name, PlaylistData playlist) async {
    final renamed = await _perform(() => repository.rename(playlist.id, name));
    if (_disposed || renamed != true) return;
    playlist.name = name;
    notifyListeners();
  }

  Future<void> delete(PlaylistData playlist) async {
    final success = await _perform(() async {
      await repository.delete(playlist.id);
      return true;
    });
    if (success != true) return;
    if (_disposed) return;
    playlists.remove(playlist);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
