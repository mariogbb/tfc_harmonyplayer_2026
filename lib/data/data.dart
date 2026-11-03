import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';
import 'package:player/model/song.dart';
import 'package:player/control/media_control.dart';
import 'package:player/data/repositories/music_library_repository.dart';
import 'package:player/data/repositories/artwork_repository.dart';
import 'package:player/data/repositories/playlist_repository.dart';
import 'package:player/data/services/artwork/local_artwork_service.dart';
import 'package:player/ui/playlists/playlist_controller.dart';
import 'package:player/ui/library/library_controller.dart';

class PlayerData extends ChangeNotifier {
  static final PlayerData _playerData = PlayerData.internal();

  // Permanent global data
  late final List<SongData> songList = [];
  late final List<AlbumData> albumList = [];
  late final List<ArtistData> artistList = [];
  late final PlayerHandler handler;
  late MusicLibraryRepository _musicLibrary;
  late ArtworkRepository _artworkRepository;
  late LocalArtworkService _localArtwork;
  LibraryController? _libraryController;
  LibraryController get libraryController => _libraryController!;
  PlaylistController? _playlistController;
  PlaylistController get playlistController => _playlistController!;
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
    _libraryController?.removeListener(_onLibraryChanged);
    _libraryController?.dispose();
    _libraryController = LibraryController(
      repository: _musicLibrary,
      artworkRepository: _artworkRepository,
      localArtwork: _localArtwork,
      songs: songList,
      albums: albumList,
      artists: artistList,
    )..addListener(_onLibraryChanged);
  }

  void _onLibraryChanged() {
    if (!_disposed) notifyListeners();
  }

  void configurePlaylists(PlaylistRepository repository) {
    _playlistController?.dispose();
    _playlistController = PlaylistController(repository);
  }

  @override
  void dispose() {
    _disposed = true;
    _libraryController?.removeListener(_onLibraryChanged);
    _libraryController?.dispose();
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

  Future<void> initState() async {
    try {
      if (await loadSongs()) await _playlistController!.load(songList);
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'music initialization',
        ),
      );
      if (!_disposed) libraryController.reportFailure(error);
    }
  }

  Future<bool> loadSongs() => libraryController.load(
    smartFilterEnabled: Settings.getValue<bool>(
      'smartFilterEnabled',
      defaultValue: true,
    )!,
    minimumDurationSeconds: Settings.getValue<double>(
      'filterDuration',
      defaultValue: 0,
    )!.toInt(),
  );
}
