import 'dart:io';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:player/data/data.dart';
import 'package:player/data/dao.dart';
import 'package:player/data/repositories/artwork_repository.dart';
import 'package:player/data/repositories/music_library_repository.dart';
import 'package:player/data/repositories/listening_history_repository.dart';
import 'package:player/data/repositories/playlist_repository.dart';
import 'package:player/data/services/artwork/database_artwork_cache.dart';
import 'package:player/data/services/artwork/deezer_artwork_service.dart';
import 'package:player/data/services/artwork/local_artwork_service.dart';
import 'package:player/data/services/music_library/desktop_music_library_service.dart';
import 'package:player/data/services/music_library/platform_music_library_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:player/app/app_resources.dart';
import 'package:player/data/settings.dart';
import 'package:player/data/services/settings/settings_store.dart';

/// Initializes platform services before displaying the application.
Future<void> bootstrap() async {
  if (!Platform.isLinux && !Platform.isWindows) {
    await _initializeFirebase();
  }

  final prefs = await SharedPreferences.getInstance();
  final settingsStore = SharedPreferencesSettingsStore(prefs);
  final settings = PlayerSettings(settingsStore);

  await PlayerDatabase.instance.initState();
  final history = SqliteListeningHistoryRepository(
    PlayerDatabase.instance.database,
  );
  PlayerData.instance.configurePlaylists(
    SqlitePlaylistRepository(PlayerDatabase.instance.database),
  );
  final musicService = Platform.isLinux || Platform.isWindows
      ? DesktopMusicLibraryService()
      : PlatformMusicLibraryService();
  PlayerData.instance.configureMusicLibrary(
    DefaultMusicLibraryRepository(
      service: musicService,
      loadPlayedTime: history.playedTime,
    ),
  );
  final httpClient = http.Client();
  PlayerData.instance.configureArtwork(
    ArtworkRepository(
      cache: DatabaseArtworkCache(PlayerDatabase.instance),
      search: DeezerArtworkService(httpClient),
    ),
    LocalArtworkService(),
  );
  PlayerData.instance.configureRefreshCoordinator(settingsStore);
  try {
    await PlayerData.instance.initHandler(history);
  } catch (_) {
    httpClient.close();
    await PlayerDatabase.instance.database.close();
    rethrow;
  }
  AppResources.instance = AppResources(
    data: PlayerData.instance,
    database: PlayerDatabase.instance,
    httpClient: httpClient,
    settings: settings,
  );
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  try {
    await FirebaseAuth.instance.signInAnonymously();
  } on FirebaseAuthException catch (error, stack) {
    developer.log(
      'Anonymous sign-in failed; continuing without it.',
      name: 'startup',
      error: error,
      stackTrace: stack,
    );
  }

  try {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await remoteConfig.setDefaults({'cast_enabled': false});
    remoteConfig.onConfigUpdated.listen((event) async {
      await remoteConfig.activate();
    });
    await remoteConfig.fetchAndActivate();
  } on FirebaseException catch (error, stack) {
    developer.log(
      'Remote configuration failed; using defaults.',
      name: 'startup',
      error: error,
      stackTrace: stack,
    );
  }
}
