import 'package:flutter_test/flutter_test.dart';
import 'package:player/data/repositories/listening_history_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  test('records consecutive durations without losing updates', () async {
    sqfliteFfiInit();
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
    );
    addTearDown(database.close);
    await database.execute(
      'CREATE TABLE SONGS(ID INT PRIMARY KEY, PLAYEDTIME INT)',
    );
    final history = SqliteListeningHistoryRepository(database);
    expect(await history.playedTime(1), Duration.zero);
    await Future.wait([
      history.record(1, const Duration(seconds: 2)),
      history.record(1, const Duration(seconds: 3)),
    ]);
    expect(await history.playedTime(1), const Duration(seconds: 5));
    await database.close();
    await expectLater(
      history.record(1, const Duration(seconds: 1)),
      throwsA(isA<Exception>()),
    );
  });
}
