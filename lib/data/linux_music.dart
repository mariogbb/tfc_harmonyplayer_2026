import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:player/model/library_metadata.dart';

/// Finds local music without relying on Android's media library.
class LinuxMusicLibrary {
  static const extensions = {
    '.mp3',
    '.ogg',
    '.opus',
    '.flac',
    '.wav',
    '.m4a',
    '.aac',
  };

  Future<String?> musicDirectory() async {
    if (Platform.isWindows) {
      final home = Platform.environment['USERPROFILE'];
      return home == null ? null : path.join(home, 'Music');
    }
    final home = Platform.environment['HOME'];
    try {
      final result = await Process.run('xdg-user-dir', ['MUSIC']);
      final directory = (result.stdout as String).trim();
      // xdg-user-dir returns HOME when no music directory is configured.
      if (result.exitCode == 0 && directory.isNotEmpty && directory != home) {
        return directory;
      }
    } on ProcessException catch (_) {}
    return home == null ? null : path.join(home, 'Music');
  }

  // FNV-1a provides IDs that stay the same across application restarts.
  static int stableId(String value) {
    var hash = 2166136261;
    for (final byte in utf8.encode(value)) {
      hash = ((hash ^ byte) * 16777619) & 0x7fffffff;
    }
    return hash;
  }

  Future<List<SongMetadata>> scan(String directory) async {
    final songs = <SongMetadata>[];
    final root = Directory(directory);
    if (!await root.exists()) return songs;
    try {
      await for (final entity in root.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File ||
            !extensions.contains(path.extension(entity.path).toLowerCase())) {
          continue;
        }
        try {
          final filePath = path.absolute(entity.path);
          final tags = <String, dynamic>{};
          var duration = 0;
          try {
            final result = await Process.run('ffprobe', [
              '-v',
              'error',
              '-show_entries',
              'format=duration:format_tags=title,artist,album,track',
              '-of',
              'json',
              filePath,
            ]);
            if (result.exitCode == 0) {
              final format =
                  (jsonDecode(result.stdout as String) as Map)['format']
                      as Map?;
              if (format != null) {
                duration =
                    ((double.tryParse('${format['duration']}') ?? 0) * 1000)
                        .round();
                final rawTags = format['tags'];
                if (rawTags is Map) {
                  rawTags.forEach(
                    (key, value) => tags[key.toString().toLowerCase()] = value,
                  );
                }
              }
            }
          } on ProcessException catch (_) {
          } on FormatException catch (_) {}
          final title =
              tags['title']?.toString() ??
              path.basenameWithoutExtension(filePath);
          final artist = tags['artist']?.toString() ?? 'Unknown artist';
          final album = tags['album']?.toString() ?? 'Unknown album';
          songs.add(
            SongMetadata(
              id: stableId('song:$filePath'),
              data: filePath,
              uri: filePath,
              title: title,
              artist: artist,
              artistId: stableId('artist:$artist'),
              album: album,
              albumId: stableId('album:$artist\u0000$album'),
              duration: duration,
              track:
                  int.tryParse('${tags['track'] ?? ''}'.split('/').first) ?? 0,
            ),
          );
        } on FileSystemException catch (_) {}
      }
    } on FileSystemException catch (_) {
      // Return files already discovered if a directory is inaccessible.
    }
    return songs;
  }
}
