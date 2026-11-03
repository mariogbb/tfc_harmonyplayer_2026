import 'package:player/model/playlist.dart';
import 'package:player/model/song.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

abstract class PlaylistRepository {
  Future<List<PlaylistData>> load(List<SongData> songs);
  Future<PlaylistData?> create(String name);
  Future<bool> rename(int playlistId, String name);
  Future<void> delete(int playlistId);
  Future<void> addSong(int playlistId, int songId);
  Future<void> removeSong(int playlistId, int songId);
}

/// Uses the existing playlist tables without changing IDs or removing unknown songs.
class SqlitePlaylistRepository implements PlaylistRepository {
  SqlitePlaylistRepository(this.database);

  final Database database;

  @override
  Future<List<PlaylistData>> load(List<SongData> songs) async {
    final songsById = {for (final song in songs) song.id: song};
    final rows = await database.query(
      'PLAYLISTS',
      columns: ['ID', 'PLAYLIST_NAME'],
    );
    final memberships = await database.query(
      'PLAYLIST_SONGS',
      columns: ['PLAYLIST_ID', 'SONG_ID'],
    );
    final songsByPlaylist = <int, List<SongData>>{};
    for (final row in memberships) {
      final playlistId = row['PLAYLIST_ID'] as int;
      final song = songsById[row['SONG_ID'] as int];
      if (song != null) {
        (songsByPlaylist[playlistId] ??= []).add(song);
      }
    }
    return rows.map((row) {
      final id = row['ID'] as int;
      return PlaylistData(
        id: id,
        name: row['PLAYLIST_NAME'] as String,
        songs: songsByPlaylist[id] ?? [],
      );
    }).toList();
  }

  @override
  Future<PlaylistData?> create(String name) async {
    return database.transaction((txn) async {
      final existing = await txn.query(
        'PLAYLISTS',
        columns: ['ID'],
        where: 'PLAYLIST_NAME = ?',
        whereArgs: [name],
        limit: 1,
      );
      if (existing.isNotEmpty) return null;
      final id = await txn.insert('PLAYLISTS', {'PLAYLIST_NAME': name});
      return PlaylistData(id: id, name: name, songs: []);
    });
  }

  @override
  Future<bool> rename(int playlistId, String name) async {
    return database.transaction((txn) async {
      final existing = await txn.query(
        'PLAYLISTS',
        columns: ['ID'],
        where: 'PLAYLIST_NAME = ? AND ID != ?',
        whereArgs: [name, playlistId],
        limit: 1,
      );
      if (existing.isNotEmpty) return false;
      final count = await txn.update(
        'PLAYLISTS',
        {'PLAYLIST_NAME': name},
        where: 'ID = ?',
        whereArgs: [playlistId],
      );
      return count > 0;
    });
  }

  @override
  Future<void> delete(int playlistId) async {
    await database.transaction((txn) async {
      await txn.delete(
        'PLAYLIST_SONGS',
        where: 'PLAYLIST_ID = ?',
        whereArgs: [playlistId],
      );
      await txn.delete('PLAYLISTS', where: 'ID = ?', whereArgs: [playlistId]);
    });
  }

  @override
  Future<void> addSong(int playlistId, int songId) async {
    await database.transaction((txn) async {
      final existing = await txn.query(
        'PLAYLIST_SONGS',
        columns: ['SONG_ID'],
        where: 'PLAYLIST_ID = ? AND SONG_ID = ?',
        whereArgs: [playlistId, songId],
        limit: 1,
      );
      if (existing.isEmpty) {
        await txn.insert('PLAYLIST_SONGS', {
          'PLAYLIST_ID': playlistId,
          'SONG_ID': songId,
        });
      }
    });
  }

  @override
  Future<void> removeSong(int playlistId, int songId) async {
    await database.delete(
      'PLAYLIST_SONGS',
      where: 'PLAYLIST_ID = ? AND SONG_ID = ?',
      whereArgs: [playlistId, songId],
    );
  }
}
