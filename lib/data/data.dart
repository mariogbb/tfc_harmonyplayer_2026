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
import 'package:player/data/services/music_library/music_library_service.dart';

class PlayerData extends ChangeNotifier {
  static final PlayerData _playerData = PlayerData.internal();

  // Permanent global data
  late final List<SongData> songList = [];
  late final List<AlbumData> albumList = [];
  late final List<ArtistData> artistList = [];
  late final List<PlaylistData> playlists = [];
  late final PlayerHandler handler;
  late MusicLibraryService _musicLibrary;

  factory PlayerData() {
    return _playerData;
  }

  static PlayerData get instance => _playerData;

  PlayerData.internal();

  void configureMusicLibrary(MusicLibraryService musicLibrary) {
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
    final library = await _musicLibrary.scan();
    final filteredSongs = filterLibrarySongs(
      library.songs,
      smartFilterEnabled: Settings.getValue<bool>(
        'smartFilterEnabled',
        defaultValue: true,
      )!,
      minimumDurationSeconds: Settings.getValue<double>(
        'filterDuration',
        defaultValue: 0,
      )!.toInt(),
    );
    final albumIds = filteredSongs.map((song) => song.albumId).toSet();
    final artistIds = filteredSongs.map((song) => song.artistId).toSet();

    for (final album in library.albums) {
      if (library.filterEntitiesBeforeLoading && !albumIds.contains(album.id)) {
        continue;
      }
      albumList.add(AlbumData(album));
    }

    for (final song in filteredSongs) {
      try {
        AlbumData album = albumList.firstWhere(
          (element) => element.id == song.albumId!,
        );

        bool isSongOnDatabase = await PlayerDatabase.instance
            .findSongInDatabase(song.id);

        Duration playedTime = Duration.zero;

        if (isSongOnDatabase) {
          playedTime = await PlayerDatabase.instance.getSongPlayedTime(song.id);
        }

        songList.add(
          SongData(model: song, albumModel: album, playedTime: playedTime),
        );
      } catch (_) {}
    }

    for (final model in library.artists) {
      if (library.filterEntitiesBeforeLoading &&
          !artistIds.contains(model.id)) {
        continue;
      }
      artistList.add(ArtistData(model));
    }

    albumList.retainWhere((element) => element.songList.isNotEmpty);
    artistList.retainWhere((element) => element.albumList.isNotEmpty);
  }
}
