import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';
import 'package:player/model/playlist.dart';
import 'package:player/model/song.dart';
import 'package:player/control/media_control.dart';
import 'package:player/data/repositories/music_library_repository.dart';
import 'package:player/data/repositories/artwork_repository.dart';
import 'package:player/data/repositories/playlist_repository.dart';
import 'package:player/data/services/artwork/local_artwork_service.dart';
import 'package:player/ui/playlists/playlist_controller.dart';

class PlayerData extends ChangeNotifier {
  static final PlayerData _playerData = PlayerData.internal();

  // Permanent global data
  late final List<SongData> songList = [];
  late final List<AlbumData> albumList = [];
  late final List<ArtistData> artistList = [];
  late final List<PlaylistData> playlists = [];
  late final PlayerHandler handler;
  late MusicLibraryRepository _musicLibrary;
  late ArtworkRepository _artworkRepository;
  late LocalArtworkService _localArtwork;
  PlaylistController? _playlistController;
  bool _disposed = false;

  factory PlayerData() {
    return _playerData;
  }

  static PlayerData get instance => _playerData;

  PlayerData.internal();

  void configureMusicLibrary(MusicLibraryRepository musicLibrary) {
    _musicLibrary = musicLibrary;
  }

  void configureArtwork(ArtworkRepository artwork, LocalArtworkService local) {
    _artworkRepository = artwork;
    _localArtwork = local;
  }

  void configurePlaylists(PlaylistRepository repository) {
    _playlistController?.removeListener(_onPlaylistsChanged);
    _playlistController?.dispose();
    _playlistController = PlaylistController(repository, playlists: playlists)
      ..addListener(_onPlaylistsChanged);
  }

  void _onPlaylistsChanged() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _playlistController?.removeListener(_onPlaylistsChanged);
    _playlistController?.dispose();
    super.dispose();
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
    await _playlistController!.load(songList);
  }

  Future<PlaylistData?> createPlaylist(String name) =>
      _playlistController!.create(name);

  Future<void> removeSongFromPlaylist(PlaylistData playlist, SongData data) =>
      _playlistController!.removeSong(playlist, data);

  Future<void> addSongToPlaylist(PlaylistData playlist, SongData data) =>
      _playlistController!.addSong(playlist, data);

  Future<void> renamePlaylist(String newName, PlaylistData playlist) =>
      _playlistController!.rename(newName, playlist);

  Future<void> deletePlaylist(PlaylistData playlist) =>
      _playlistController!.delete(playlist);

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
    final localArtwork = await Future.wait(
      library.albums.map((album) => _localArtwork.loadAlbumArtwork(album.id)),
    );
    for (var i = 0; i < library.albums.length; i++) {
      final album = AlbumData(
        library.albums[i],
        artwork: localArtwork[i],
        songs: songList,
        artists: artistList,
      );
      albumList.add(album);
      unawaited(_loadAlbumUrl(album));
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
            artists: artistList,
          ),
        );
      } catch (_) {}
    }

    for (final model in library.artists) {
      final artist = ArtistData(model, albums: albumList, songs: songList);
      artistList.add(artist);
      unawaited(_loadArtistUrl(artist));
    }
  }

  Future<void> _loadAlbumUrl(AlbumData album) async {
    final url = await _artworkRepository.albumUrl(album.id, album.name);
    if (_disposed || !albumList.contains(album)) return;
    album.imageURL = url;
    if (url != null) notifyListeners();
  }

  Future<void> _loadArtistUrl(ArtistData artist) async {
    final url = await _artworkRepository.artistUrl(artist.id, artist.name);
    if (_disposed || !artistList.contains(artist)) return;
    artist.imageURL = url;
    if (url != null) notifyListeners();
  }
}
