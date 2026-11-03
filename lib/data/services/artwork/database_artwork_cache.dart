import 'package:player/data/dao.dart';
import 'package:player/data/repositories/artwork_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseArtworkCache implements ArtworkCache {
  DatabaseArtworkCache(this.database);

  final PlayerDatabase database;

  Future<String?> _load(String table, int id) async {
    final rows = await database.database.query(
      table,
      columns: ['URL'],
      where: 'ID = ?',
      whereArgs: [id],
    );
    return rows.isEmpty ? null : rows.first['URL'] as String?;
  }

  Future<void> _save(String table, int id, String url) async {
    await database.database.insert(table, {
      'ID': id,
      'URL': url,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<String?> loadAlbum(int id) => _load('ALBUMS', id);
  @override
  Future<String?> loadArtist(int id) => _load('ARTISTS', id);
  @override
  Future<void> saveAlbum(int id, String url) => _save('ALBUMS', id, url);
  @override
  Future<void> saveArtist(int id, String url) => _save('ARTISTS', id, url);
}
