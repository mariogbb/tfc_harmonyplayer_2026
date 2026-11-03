import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:player/data/linux_music.dart';

void main() {
  test('reads metadata from a real MP3 when ffmpeg is available', () async {
    final root = await Directory.systemTemp.createTemp('harmony_mp3_test_');
    addTearDown(() => root.delete(recursive: true));
    try {
      final result = await Process.run('ffmpeg', [
        '-v',
        'error',
        '-f',
        'lavfi',
        '-i',
        'sine=frequency=440:duration=1',
        '-metadata',
        'title=Prueba Harmony',
        '-metadata',
        'artist=Harmony Player',
        path.join(root.path, 'test.mp3'),
      ]);
      expect(result.exitCode, 0, reason: '${result.stderr}');
    } on ProcessException catch (_) {
      return; // ffmpeg is only needed for this integration test.
    }
    final songs = await LinuxMusicLibrary().scan(root.path);
    expect(songs, hasLength(1));
    expect(songs.single.title, 'Prueba Harmony');
    expect(songs.single.artist, 'Harmony Player');
    expect(songs.single.duration, greaterThan(0));
  });

  test(
    'finds music recursively with stable IDs and ignores other files',
    () async {
      final root = await Directory.systemTemp.createTemp('harmony_music_test_');

      addTearDown(() => root.delete(recursive: true));

      final nested = await Directory(path.join(root.path, 'album')).create();

      await File(path.join(nested.path, 'Song.MP3')).writeAsBytes([0, 1, 2]);
      await File(path.join(root.path, 'notes.txt')).writeAsString('not music');

      final library = LinuxMusicLibrary();
      final first = await library.scan(root.path);
      final second = await library.scan(root.path);

      expect(first, hasLength(1));
      expect(first.single.title, 'Song');
      expect(first.single.data, path.join(nested.path, 'Song.MP3'));
      expect(first.single.id, second.single.id);
      expect(await library.scan(path.join(root.path, 'missing')), isEmpty);
    },
  );
}
