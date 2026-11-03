import 'dart:convert';
import 'dart:io';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:path/path.dart' as path;

/// Finds local music without relying on Android's media library.
class LinuxMusicLibrary {
  static const extensions = {
    '.mp3',
    '.ogg',
    '.opus',
    '.flac',
    '.wav',
    '.m4a',
    '.aac'
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

  Future<List<SongModel>> scan(String directory) async {
    final songs = <SongModel>[];
    final root = Directory(directory);
    if (!await root.exists()) return songs;
    try {
      await for (final entity
          in root.list(recursive: true, followLinks: false)) {
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
              final format = (jsonDecode(result.stdout as String)
                  as Map)['format'] as Map?;
              if (format != null) {
                duration =
                    ((double.tryParse('${format['duration']}') ?? 0) * 1000)
                        .round();
                final rawTags = format['tags'];
                if (rawTags is Map) {
                  rawTags.forEach((key, value) =>
                      tags[key.toString().toLowerCase()] = value);
                }
              }
            }
          } on ProcessException catch (_) {
          } on FormatException catch (_) {}
          final title = tags['title']?.toString() ??
              path.basenameWithoutExtension(filePath);
          final artist = tags['artist']?.toString() ?? 'Unknown artist';
          final album = tags['album']?.toString() ?? 'Unknown album';
          songs.add(SongModel({
            '_id': stableId('song:$filePath'),
            '_data': filePath,
            '_uri': filePath,
            '_display_name': path.basename(filePath),
            '_display_name_wo_ext': path.basenameWithoutExtension(filePath),
            '_size': await entity.length(),
            'title': title,
            'artist': artist,
            'artist_id': stableId('artist:$artist'),
            'album': album,
            'album_id': stableId('album:$artist\u0000$album'),
            'duration': duration,
            'track':
                int.tryParse('${tags['track'] ?? ''}'.split('/').first) ?? 0,
            'file_extension': path.extension(filePath).replaceFirst('.', ''),
          }));
        } on FileSystemException catch (_) {}
      }
    } on FileSystemException catch (_) {
      // Return files already discovered if a directory is inaccessible.
    }
    return songs;
  }
}
