import 'dart:typed_data';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:player/data/repositories/playlist_repository.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';
import 'package:player/model/library_metadata.dart';
import 'package:player/model/song.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database database;
  late SqlitePlaylistRepository repository;

  setUp(() async {
    sqfliteFfiInit();
    database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await database.execute(
      'CREATE TABLE PLAYLISTS(ID INTEGER PRIMARY KEY AUTOINCREMENT, PLAYLIST_NAME VARCHAR(50) NOT NULL)',
    );
    await database.execute(
      'CREATE UNIQUE INDEX AK_NAME ON PLAYLISTS(PLAYLIST_NAME)',
    );
    await database.execute(
      'CREATE TABLE PLAYLIST_SONGS(SONG_ID INT UNSIGNED NOT NULL, PLAYLIST_ID INT UNSIGNED NOT NULL)',
    );
    repository = SqlitePlaylistRepository(database);
  });

  tearDown(() => database.close());

  SongData song(int id) {
    final songs = <SongData>[];
    final artists = <ArtistData>[];
    final album = AlbumData(
      const AlbumMetadata(id: 1, album: 'Album'),
      artwork: Uint8List(0),
      songs: songs,
      artists: artists,
    );
    return SongData(
      model: SongMetadata(id: id, data: '/$id.mp3', title: 'Song'),
      albumModel: album,
      playedTime: Duration.zero,
      artists: artists,
    );
  }

  test(
    'loads existing IDs and preserves songs missing from the library',
    () async {
      await database.insert('PLAYLISTS', {
        'ID': 5,
        'PLAYLIST_NAME': 'Existing',
      });
      await database.insert('PLAYLIST_SONGS', {
        'PLAYLIST_ID': 5,
        'SONG_ID': 11,
      });
      await database.insert('PLAYLIST_SONGS', {
        'PLAYLIST_ID': 5,
        'SONG_ID': 12,
      });
      final playlists = await repository.load([song(11)]);
      expect(playlists.single.id, 5);
      expect(playlists.single.songs.map((song) => song.id), [11]);
      expect(await database.query('PLAYLIST_SONGS'), hasLength(2));
      expect(
        (await repository.load([song(11), song(12)])).single.songs
            .map((s) => s.id),
        [11, 12],
      );
    },
  );

  test(
    'persists membership without duplicates and removes only from one playlist',
    () async {
      final first = (await repository.create('First'))!;
      final second = (await repository.create('Second'))!;
      await repository.addSong(first.id, 42);
      await repository.addSong(first.id, 42);
      await repository.addSong(second.id, 42);
      expect(await database.query('PLAYLIST_SONGS'), hasLength(2));
      await repository.removeSong(first.id, 42);
      final playlists = await repository.load([song(42)]);
      expect(playlists.first.songs, isEmpty);
      expect(playlists.last.songs.single.id, 42);
    },
  );

  test(
    'creates, renames and deletes without modifying other playlists',
    () async {
      final first = (await repository.create('First'))!;
      final second = (await repository.create('Second'))!;
      expect(await repository.create('First'), isNull);
      expect(await repository.rename(first.id, 'Second'), isFalse);
      expect(await repository.rename(first.id, 'Renamed'), isTrue);
      await repository.addSong(first.id, 1);
      await repository.addSong(second.id, 1);
      await repository.delete(first.id);
      final playlists = await repository.load([song(1)]);
      expect(playlists.single.id, second.id);
      expect(playlists.single.songs.single.id, 1);
      expect(await database.query('PLAYLIST_SONGS'), hasLength(1));
    },
  );

  test('playlist changes survive closing and reopening the database', () async {
    final directory = await Directory.systemTemp.createTemp(
      'harmony_playlist_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final path = '${directory.path}/playlists.db';
    var disk = await databaseFactoryFfi.openDatabase(path);
    await disk.execute(
      'CREATE TABLE PLAYLISTS(ID INTEGER PRIMARY KEY AUTOINCREMENT, PLAYLIST_NAME VARCHAR(50) NOT NULL)',
    );
    await disk.execute(
      'CREATE TABLE PLAYLIST_SONGS(SONG_ID INT UNSIGNED NOT NULL, PLAYLIST_ID INT UNSIGNED NOT NULL)',
    );
    final stored = SqlitePlaylistRepository(disk);
    final playlist = (await stored.create('Saved'))!;
    await stored.addSong(playlist.id, 42);
    expect(await stored.rename(playlist.id, 'Renamed'), isTrue);
    await disk.close();

    disk = await databaseFactoryFfi.openDatabase(path);
    addTearDown(disk.close);
    final reloaded = await SqlitePlaylistRepository(disk).load([song(42)]);
    expect(reloaded.single.id, playlist.id);
    expect(reloaded.single.name, 'Renamed');
    expect(reloaded.single.songs.single.id, 42);
  });
}
