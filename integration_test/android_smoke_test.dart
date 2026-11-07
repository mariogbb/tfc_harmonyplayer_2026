import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path;
import 'package:player/control/audio_backend.dart';
import 'package:player/data/repositories/playlist_repository.dart';
import 'package:sqflite/sqflite.dart';

import 'desktop_smoke_test.dart' show silentWav;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android persists a playlist and plays a local file', (
    tester,
  ) async {
    if (!Platform.isAndroid) return;
    await tester.runAsync(() async {
      final directory = await Directory.systemTemp.createTemp('harmony_smoke_');
      addTearDown(() => directory.delete(recursive: true));
      final file = File(path.join(directory.path, 'test.wav'));
      await file.writeAsBytes(silentWav());
      final databasePath = path.join(directory.path, 'playlist.db');
      var database = await openDatabase(databasePath);
      await database.execute(
        'CREATE TABLE PLAYLISTS(ID INTEGER PRIMARY KEY AUTOINCREMENT, PLAYLIST_NAME TEXT NOT NULL)',
      );
      await database.execute(
        'CREATE TABLE PLAYLIST_SONGS(SONG_ID INTEGER NOT NULL, PLAYLIST_ID INTEGER NOT NULL)',
      );
      final repository = SqlitePlaylistRepository(database);
      final playlist = (await repository.create('Smoke test'))!;
      await repository.addSong(playlist.id, 42);
      await database.close();
      database = await openDatabase(databasePath);
      addTearDown(database.close);
      expect((await database.query('PLAYLIST_SONGS')).single['SONG_ID'], 42);

      final backend = AudioplayersBackend();
      addTearDown(backend.dispose);
      await backend.initialize();
      await backend.playFile(file.path);
      expect(backend.state, AudioBackendState.playing);
      await backend.pause();
      expect(backend.state, AudioBackendState.paused);
    });
  }, skip: !Platform.isAndroid);
}
