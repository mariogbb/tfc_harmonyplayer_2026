import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:player/data/data.dart';
import 'package:player/data/dao.dart';
import 'package:player/data/repositories/music_library_repository.dart';
import 'package:player/data/services/music_library/desktop_music_library_service.dart';
import 'package:player/data/services/music_library/platform_music_library_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Initializes platform services and returns whether to show the welcome screen.
Future<bool> bootstrap() async {
  if (!Platform.isLinux && !Platform.isWindows) {
    await _initializeFirebase();
  }

  final prefs = await SharedPreferences.getInstance();
  await Settings.init();
  Settings.ensureCacheProvider();

  final showWelcome = await initializeWelcomePreference(prefs);

  await PlayerDatabase.instance.initState();
  final musicService = Platform.isLinux || Platform.isWindows
      ? DesktopMusicLibraryService()
      : PlatformMusicLibraryService();
  PlayerData.instance.configureMusicLibrary(
    DefaultMusicLibraryRepository(
      service: musicService,
      loadPlayedTime: PlayerDatabase.instance.getSongPlayedTime,
    ),
  );
  await PlayerData.instance.initHandler();
  return showWelcome;
}

/// Preserves the existing first-launch preference and returns its initial state.
Future<bool> initializeWelcomePreference(SharedPreferences prefs) async {
  final showWelcome = prefs.getInt('initScreen') == null;
  if (showWelcome) {
    await prefs.setInt('initScreen', 1);
  }

  return showWelcome;
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
  } on FirebaseAuthException catch (_) {}

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
  } on FirebaseException catch (_) {}
}
