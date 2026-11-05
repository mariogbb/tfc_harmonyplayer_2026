import 'package:flutter/foundation.dart';
import 'package:player/ui/library/library_controller.dart';
import 'package:player/ui/playlists/playlist_controller.dart';

/// Coordinates refreshing the library and resolving saved playlist songs.
class LibraryRefreshCoordinator {
  LibraryRefreshCoordinator({
    required this.library,
    required this.playlists,
    required this.smartFilterEnabled,
    required this.minimumDurationSeconds,
  });

  final LibraryController library;
  final PlaylistController playlists;
  final bool Function() smartFilterEnabled;
  final int Function() minimumDurationSeconds;
  int _generation = 0;
  bool _disposed = false;

  Future<void> refresh() async {
    final generation = ++_generation;
    playlists.invalidateLoads();
    try {
      final loaded = await library.load(
        smartFilterEnabled: smartFilterEnabled(),
        minimumDurationSeconds: minimumDurationSeconds(),
      );
      if (loaded && !_disposed && generation == _generation) {
        await playlists.load(library.songList);
      }
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'music initialization',
        ),
      );
      if (!_disposed && generation == _generation) library.reportFailure(error);
    }
  }

  void dispose() {
    _disposed = true;
    _generation++;
    playlists.invalidateLoads();
  }
}
