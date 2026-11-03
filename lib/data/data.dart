import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';
import 'package:player/data/dao.dart';
import 'package:player/model/playlist.dart';
import 'package:player/model/song.dart';
import 'package:player/control/media_control.dart';
import 'package:player/data/repositories/music_library_repository.dart';

class PlayerData extends ChangeNotifier {
  static final PlayerData _playerData = PlayerData.internal();

  // Permanent global data
  late final List<SongData> songList = [];
  late final List<AlbumData> albumList = [];
  late final List<ArtistData> artistList = [];
  late final List<PlaylistData> playlists = [];
  late final PlayerHandler handler;
  late MusicLibraryRepository _musicLibrary;

  factory PlayerData() {
    return _playerData;
  }

  static PlayerData get instance => _playerData;

  PlayerData.internal();

  void configureMusicLibrary(MusicLibraryRepository musicLibrary) {
    _musicLibrary = musicLibrary;
  }

  // Init state
  Future<void> initHandler() async {
    if (Platform.isLinux || Platform.isWindows) {
      handler = PlayerHandler();
      return;
    }
    handler = await AudioService.init(
      builder: () => PlayerHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'dev.mariobesada.player.channel.audio',
        preloadArtwork: true,
        androidStopForegroundOnPause: true,
        androidNotificationClickStartsActivity: true,
        androidNotificationOngoing: true,
        androidNotificationChannelName: 'Music playback',
      ),
    );
  }

  void initState() async {
    songList.clear();
    albumList.clear();
    artistList.clear();
    playlists.clear();

    await loadSongs();
    List<PlaylistData> loadedPlaylists = await PlayerDatabase().loadPlaylists();

    loadedPlaylists.forEach(playlists.add);
    notifyListeners();
  }

  Future<PlaylistData?> createPlaylist(String name) async {
    PlaylistData? newPlaylist;

    if (playlists.where((element) => element.name == name).isEmpty) {
      newPlaylist = await PlayerDatabase.instance.createPlaylist(name);

      if (newPlaylist != null) {
        playlists.add(newPlaylist);
      }
    }

    notifyListeners();

    return newPlaylist;
  }

  Future<void> removeSongFromPlaylist(
    PlaylistData playlist,
    SongData data,
  ) async {
    if (playlist.songs.contains(data)) {
      playlist.songs.remove(data);
      notifyListeners();
    }
  }

  Future<void> addSongToPlaylist(PlaylistData playlist, SongData data) async {
    if (!playlist.songs.contains(data)) {
      playlist.songs.add(data);
      notifyListeners();
    }
  }

  void renamePlaylist(String newName, PlaylistData playlist) {}

  void deletePlaylist(PlaylistData playlist) async {
    await PlayerDatabase.instance.removePlaylistFromDatabase(playlist);
    playlists.remove(playlist);
    notifyListeners();
  }

  Future<void> loadSongs() async {
    final library = await _musicLibrary.load(
      smartFilterEnabled: Settings.getValue<bool>(
        'smartFilterEnabled',
        defaultValue: true,
      )!,
      minimumDurationSeconds: Settings.getValue<double>(
        'filterDuration',
        defaultValue: 0,
      )!.toInt(),
    );
    for (final album in library.albums) {
      albumList.add(AlbumData(album));
    }

    for (final song in library.songs) {
      try {
        AlbumData album = albumList.firstWhere(
          (element) => element.id == song.model.albumId,
        );
        songList.add(
          SongData(
            model: song.model,
            albumModel: album,
            playedTime: song.playedTime,
          ),
        );
      } catch (_) {}
    }

    for (final model in library.artists) {
      artistList.add(ArtistData(model));
    }
  }
}
