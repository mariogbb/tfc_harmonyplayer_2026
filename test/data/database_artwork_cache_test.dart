import 'package:flutter_test/flutter_test.dart';
import 'package:player/data/dao.dart';
import 'package:player/data/services/artwork/database_artwork_cache.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  test('reads existing artwork and writes to the existing tables', () async {
    sqfliteFfiInit();
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
    );
    addTearDown(database.close);
    await database.execute('CREATE TABLE ALBUMS(ID INT PRIMARY KEY, URL TEXT)');
    await database.execute(
      'CREATE TABLE ARTISTS(ID INT PRIMARY KEY, URL TEXT)',
    );
    await database.insert('ALBUMS', {'ID': 12, 'URL': 'existing'});

    final playerDatabase = PlayerDatabase.internal()..database = database;
    final cache = DatabaseArtworkCache(playerDatabase);

    expect(await cache.loadAlbum(12), 'existing');
    expect(await cache.loadArtist(3), isNull);

    await cache.saveAlbum(12, 'updated');
    await cache.saveArtist(3, 'artist');

    expect(await cache.loadAlbum(12), 'updated');
    expect(await cache.loadArtist(3), 'artist');
  });
}
