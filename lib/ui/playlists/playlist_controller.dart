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

  Future<void> load(List<SongData> songs) async {
    final loaded = await repository.load(songs);
    if (_disposed) return;
    playlists
      ..clear()
      ..addAll(loaded);
    notifyListeners();
  }

  Future<PlaylistData?> create(String name) async {
    if (playlists.any((playlist) => playlist.name == name)) return null;
    final playlist = await repository.create(name);
    if (_disposed) return playlist;
    if (playlist != null) playlists.add(playlist);
    notifyListeners();
    return playlist;
  }

  Future<void> addSong(PlaylistData playlist, SongData song) async {
    if (playlist.songs.contains(song)) return;
    await repository.addSong(playlist.id, song.id);
    if (_disposed) return;
    if (!playlist.songs.contains(song)) playlist.songs.add(song);
    notifyListeners();
  }

  Future<void> removeSong(PlaylistData playlist, SongData song) async {
    if (!playlist.songs.contains(song)) return;
    await repository.removeSong(playlist.id, song.id);
    if (_disposed) return;
    playlist.songs.remove(song);
    notifyListeners();
  }

  Future<void> rename(String name, PlaylistData playlist) async {
    final renamed = await repository.rename(playlist.id, name);
    if (_disposed || !renamed) return;
    playlist.name = name;
    notifyListeners();
  }

  Future<void> delete(PlaylistData playlist) async {
    await repository.delete(playlist.id);
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
