import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path;
import 'package:player/control/audio_backend.dart';
import 'package:player/data/linux_music.dart';
import 'package:player/data/repositories/playlist_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Uint8List silentWav() {
  const sampleRate = 16000;
  const dataLength = sampleRate * 2 * 2;
  final bytes = ByteData(44 + dataLength);
  void text(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      bytes.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  text(0, 'RIFF');
  bytes.setUint32(4, 36 + dataLength, Endian.little);
  text(8, 'WAVE');
  text(12, 'fmt ');
  bytes.setUint32(16, 16, Endian.little);
  bytes.setUint16(20, 1, Endian.little);
  bytes.setUint16(22, 1, Endian.little);
  bytes.setUint32(24, sampleRate, Endian.little);
  bytes.setUint32(28, sampleRate * 2, Endian.little);
  bytes.setUint16(32, 2, Endian.little);
  bytes.setUint16(34, 16, Endian.little);
  text(36, 'data');
  bytes.setUint32(40, dataLength, Endian.little);
  return bytes.buffer.asUint8List();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('desktop discovers a file, persists a playlist and plays audio', (
    tester,
  ) async {
    if (!Platform.isLinux && !Platform.isWindows) return;
    await tester.runAsync(() async {
      final directory = await Directory.systemTemp.createTemp('harmony_smoke_');
      addTearDown(() => directory.delete(recursive: true));
      final file = File(path.join(directory.path, 'test.wav'));
      await file.writeAsBytes(silentWav());
      final songs = await LinuxMusicLibrary().scan(directory.path);
      expect(songs, hasLength(1));
      expect(songs.single.data, file.path);

      sqfliteFfiInit();
      final databasePath = path.join(directory.path, 'playlist.db');
      var database = await databaseFactoryFfi.openDatabase(databasePath);
      await database.execute(
        'CREATE TABLE PLAYLISTS(ID INTEGER PRIMARY KEY AUTOINCREMENT, PLAYLIST_NAME TEXT NOT NULL)',
      );
      await database.execute(
        'CREATE TABLE PLAYLIST_SONGS(SONG_ID INTEGER NOT NULL, PLAYLIST_ID INTEGER NOT NULL)',
      );
      final playlists = SqlitePlaylistRepository(database);
      final playlist = (await playlists.create('Smoke test'))!;
      await playlists.addSong(playlist.id, songs.single.id);
      await database.close();
      database = await databaseFactoryFfi.openDatabase(databasePath);
      addTearDown(database.close);
      final rows = await database.query('PLAYLIST_SONGS');
      expect(rows.single['SONG_ID'], songs.single.id);

      final backend = AudioplayersBackend();
      addTearDown(backend.dispose);
      await backend.initialize();
      await backend.playFile(file.path);
      expect(backend.state, AudioBackendState.playing);
      await backend.pause();
      expect(backend.state, AudioBackendState.paused);
    });
  }, skip: !Platform.isLinux && !Platform.isWindows);
}
