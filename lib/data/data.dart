import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';
import 'package:player/data/dao.dart';
import 'package:player/model/playlist.dart';
import 'package:player/model/song.dart';
import 'package:player/control/media_control.dart';
import 'package:player/data/linux_music.dart';

class PlayerData extends ChangeNotifier {
  static final PlayerData _playerData = PlayerData.internal();

  // Permanent global data
  late final List<SongData> songList = [];
  late final List<AlbumData> albumList = [];
  late final List<ArtistData> artistList = [];
  late final List<PlaylistData> playlists = [];
  late final PlayerHandler handler;

  factory PlayerData() {
    return _playerData;
  }

  static PlayerData get instance => _playerData;

  PlayerData.internal();

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
      PlaylistData playlist, SongData data) async {
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

  Future loadSongs() async {
    if (Platform.isLinux || Platform.isWindows) {
      final library = LinuxMusicLibrary();
      final directory = await library.musicDirectory();
      if (directory == null) return;
      final songs = await library.scan(directory);
      for (final song in songs) {
        if (Settings.getValue<bool>('smartFilterEnabled',
                defaultValue: true)! &&
            song.title.startsWith('AUD')) {
          continue;
        }
        if (song.duration! <
            Settings.getValue<double>('filterDuration', defaultValue: 0)!
                    .toInt() *
                1000) {
          continue;
        }
        if (!artistList.any((artist) => artist.id == song.artistId)) {
          artistList.add(ArtistData(ArtistModel({
            '_id': song.artistId,
            'artist': song.artist,
          })));
        }
        var albums = albumList.where((album) => album.id == song.albumId);
        if (albums.isEmpty) {
          albumList.add(AlbumData(AlbumModel({
            '_id': song.albumId,
            'album': song.album,
            'artist': song.artist,
            'artist_id': song.artistId,
            'numsongs': 0,
          })));
          albums = albumList.where((album) => album.id == song.albumId);
        }
        final playedTime =
            await PlayerDatabase.instance.getSongPlayedTime(song.id);
        songList.add(SongData(
            model: song, albumModel: albums.first, playedTime: playedTime));
      }
      return;
    }
    if (await Permission.storage.isDenied) {
      return;
    }

    Trace songTrace = FirebasePerformance.instance.newTrace("song-load");

    await songTrace.start();

    var query = OnAudioQuery();

    List<AlbumModel> albumInfo = await query.queryAlbums();

    for (AlbumModel album in albumInfo) {
      albumList.add(AlbumData(album));
    }

    List<SongModel> info = await query.querySongs();

    songTrace.setMetric("song_number", info.length);

    for (SongModel song in info) {
      try {
        if (Settings.getValue<bool>("smartFilterEnabled",
                defaultValue: true)! &&
            song.title.startsWith("AUD")) {
          continue;
        }

        if (song.duration! <
            (Settings.getValue<double>("filterDuration", defaultValue: 0)!
                    .toInt() *
                1000)) {
          continue;
        }

        AlbumData album =
            albumList.firstWhere((element) => element.id == song.albumId!);

        bool isSongOnDatabase =
            await PlayerDatabase.instance.findSongInDatabase(song.id);

        Duration playedTime = Duration.zero;

        if (isSongOnDatabase) {
          playedTime = await PlayerDatabase.instance.getSongPlayedTime(song.id);
        }

        songList.add(
            SongData(model: song, albumModel: album, playedTime: playedTime));
      } catch (_) {}
    }

    List<ArtistModel> artistInfo = await query.queryArtists();

    for (ArtistModel model in artistInfo) {
      artistList.add(ArtistData(model));
    }

    albumList.retainWhere((element) => element.songList.isNotEmpty);
    artistList.retainWhere((element) => element.albumList.isNotEmpty);

    await songTrace.stop();
  }
}
