import 'package:sqflite_common_ffi/sqflite_ffi.dart';

abstract class ListeningHistoryRepository {
  Future<Duration> playedTime(int songId);
  Future<void> record(int songId, Duration duration);
}

class SqliteListeningHistoryRepository implements ListeningHistoryRepository {
  SqliteListeningHistoryRepository(this.database);
  final Database database;

  @override
  Future<Duration> playedTime(int songId) async {
    final rows = await database.query(
      'SONGS',
      columns: ['PLAYEDTIME'],
      where: 'ID = ?',
      whereArgs: [songId],
    );
    return rows.isEmpty
        ? Duration.zero
        : Duration(seconds: rows.first['PLAYEDTIME'] as int);
  }

  @override
  Future<void> record(int songId, Duration duration) async {
    await database.transaction((txn) async {
      final rows = await txn.query(
        'SONGS',
        columns: ['PLAYEDTIME'],
        where: 'ID = ?',
        whereArgs: [songId],
      );
      final previous = rows.isEmpty ? 0 : rows.first['PLAYEDTIME'] as int;
      await txn.insert('SONGS', {
        'ID': songId,
        'PLAYEDTIME': previous + duration.inSeconds,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }
}
