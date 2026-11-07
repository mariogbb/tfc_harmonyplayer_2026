import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:player/data/services/settings/settings_store.dart';
import 'package:player/control/media_control.dart';
import 'package:player/control/audio_backend.dart';
import 'package:player/data/repositories/listening_history_repository.dart';
import 'package:player/data/repositories/music_library_repository.dart';
import 'package:player/data/repositories/artwork_repository.dart';
import 'package:player/data/repositories/playlist_repository.dart';
import 'package:player/data/services/artwork/local_artwork_service.dart';
import 'package:player/ui/playlists/playlist_controller.dart';
import 'package:player/ui/library/library_controller.dart';
import 'package:player/app/library_refresh_coordinator.dart';

class PlayerData extends ChangeNotifier {
  static final PlayerData _playerData = PlayerData.internal();

  // Permanent global data
  late final PlayerHandler handler;
  late MusicLibraryRepository _musicLibrary;
  late ArtworkRepository _artworkRepository;
  late LocalArtworkService _localArtwork;
  LibraryController? _libraryController;
  LibraryController get libraryController => _libraryController!;
  PlaylistController? _playlistController;
  PlaylistController get playlistController => _playlistController!;
  late LibraryRefreshCoordinator refreshCoordinator;

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
    _libraryController?.dispose();
    _libraryController = LibraryController(
      repository: _musicLibrary,
      artworkRepository: _artworkRepository,
      localArtwork: _localArtwork,
    );
  }

  void configurePlaylists(PlaylistRepository repository) {
    _playlistController?.dispose();
    _playlistController = PlaylistController(repository);
  }

  @override
  void dispose() {
    _libraryController?.dispose();
    _playlistController?.dispose();
    super.dispose();
  }

  // Init state
  Future<void> initHandler(ListeningHistoryRepository history) async {
    final playerHandler = PlayerHandler.withBackend(
      AudioplayersBackend(),
      history.record,
    );
    if (Platform.isLinux || Platform.isWindows) {
      handler = playerHandler;
      return;
    }
    try {
      handler = await AudioService.init(
        builder: () => playerHandler,
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'dev.mariobesada.player.channel.audio',
          preloadArtwork: true,
          androidStopForegroundOnPause: true,
          androidNotificationClickStartsActivity: true,
          androidNotificationOngoing: true,
          androidNotificationChannelName: 'Music playback',
        ),
      );
    } catch (_) {
      playerHandler.dispose();
      rethrow;
    }
  }

  void configureRefreshCoordinator(SettingsStore settings) {
    refreshCoordinator = LibraryRefreshCoordinator(
      library: libraryController,
      playlists: playlistController,
      smartFilterEnabled: () =>
          settings.read<bool>('smartFilterEnabled', defaultValue: true)!,
      minimumDurationSeconds: () =>
          settings.read<double>('filterDuration', defaultValue: 0)!.toInt(),
    );
  }
}
