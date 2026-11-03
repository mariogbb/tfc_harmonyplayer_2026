import 'package:flutter_test/flutter_test.dart';
import 'package:player/data/dao.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database database;
  late PlayerDatabase playerDatabase;

  setUp(() async {
    sqfliteFfiInit();
    database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    playerDatabase = PlayerDatabase.internal()..database = database;
  });
  tearDown(() => database.close());

  test('song lookups propagate database errors', () async {
    await expectLater(
      playerDatabase.findSongInDatabase(1),
      throwsA(isA<DatabaseException>()),
    );
    await expectLater(
      playerDatabase.getSongPlayedTime(1),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('ranking queries propagate database errors instead of returning empty results', () async {
    await expectLater(
      playerDatabase.loadRankings(),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('ranking loads keep entries when a song is unavailable', () async {
    await database.execute(
      'CREATE TABLE RANKINGS(ID INTEGER PRIMARY KEY, RANKING_DATE TEXT)',
    );
    await database.execute(
      'CREATE TABLE RANKINGS_SONGS(SONG_ID INTEGER, RANKING_ID INTEGER)',
    );
    await database.insert('RANKINGS', {'ID': 7, 'RANKING_DATE': '2026-11-04'});
    await database.insert('RANKINGS_SONGS', {'SONG_ID': 999, 'RANKING_ID': 7});
    final result = await playerDatabase.loadRankings();
    expect(result, hasLength(1));
  });
}
