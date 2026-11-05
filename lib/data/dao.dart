import 'dart:io';

import 'package:path/path.dart';
import 'package:player/model/ranking.dart';
import 'package:player/model/song.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class PlayerDatabase {
  static final PlayerDatabase _playerDatabase = PlayerDatabase.internal();

  // Databases
  late Database database;

  factory PlayerDatabase() {
    return _playerDatabase;
  }

  static PlayerDatabase get instance => _playerDatabase;

  Future initState() async {
    if (Platform.isLinux || Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    database = await openDatabase(
      join(await getDatabasesPath(), "player_db.db"),
      onCreate: ((db, version) async {
        // Albums table
        await db.execute(
          "CREATE TABLE ALBUMS(ID INT UNSIGNED NOT NULL,URL TEXT NULL,PRIMARY KEY (ID))",
        );
        // Artist table
        await db.execute(
          "CREATE TABLE ARTISTS(ID INT UNSIGNED NOT NULL,URL TEXT NULL,PRIMARY KEY (ID))",
        );
        // Playlist table
        await db.execute(
          "CREATE TABLE PLAYLISTS(ID INTEGER PRIMARY KEY AUTOINCREMENT,PLAYLIST_NAME VARCHAR(50) NOT NULL)",
        );
        await db.execute(
          "CREATE UNIQUE INDEX AK_NAME ON PLAYLISTS(PLAYLIST_NAME)",
        );
        // Songs table
        await db.execute(
          "CREATE TABLE SONGS(ID INT UNSIGNED, PLAYEDTIME INT UNSIGNED, PRIMARY KEY (ID))",
        );
        // Playlist songs table
        await db.execute(
          "CREATE TABLE PLAYLIST_SONGS(SONG_ID INT UNSIGNED NOT NULL,PLAYLIST_ID INT UNSIGNED NOT NULL,FOREIGN KEY (PLAYLIST_ID) REFERENCES PLAYLISTS (ID) ON DELETE CASCADE ON UPDATE CASCADE)",
        );
        // Liked songs playlist
        await db.insert("PLAYLISTS", {"PLAYLIST_NAME": "Liked songs"});
        // Rankings
        await db.execute(
          "CREATE TABLE RANKINGS(ID INTEGER PRIMARY KEY AUTOINCREMENT, RANKING_DATE VARCHAR(25), RANKING_TYPE INT UNSIGNED)",
        );
        await db.execute(
          "CREATE TABLE RANKINGS_SONGS(SONG_ID INT UNSIGNED NOT NULL, RANKING_ID INT UNSIGNED NOT NULL,FOREIGN KEY (RANKING_ID) REFERENCES RANKINGS (ID) ON DELETE CASCADE ON UPDATE CASCADE)",
        );
      }),
      version: 2,
    );
  }

  PlayerDatabase.internal();

  Future<bool> findSongInDatabase(int id) async {
    final result = await database.query(
      "SONGS",
      columns: ["ID"],
      where: "ID = ?",
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  Future<void> addSongDuration(int id, Duration duration) async {
    final previousTime = await getSongPlayedTime(id);
    await database.insert("SONGS", {
      "ID": id,
      "PLAYEDTIME": (duration + previousTime).inSeconds,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Duration> getSongPlayedTime(int id) async {
    final result = await database.query(
      "SONGS",
      columns: ["PLAYEDTIME"],
      where: "ID = ?",
      whereArgs: [id],
    );
    if (result.isEmpty) return Duration.zero;
    return Duration(seconds: result.first["PLAYEDTIME"] as int);
  }

  Future<List<Ranking>> loadRankings([
    List<SongData> librarySongs = const [],
  ]) async {
    final rankingList = <Ranking>[];
    final songsById = {
      for (final song in librarySongs) song.id.toString(): song,
    };
    final rankingQuery = await database.query(
      "RANKINGS",
      columns: ["ID", "RANKING_DATE"],
    );

    for (var el in rankingQuery) {
      final songs = <SongData>[];

      List<Map> songsQuery = await database.query(
        "RANKINGS_SONGS",
        columns: ["SONG_ID"],
        where: "RANKING_ID == ?",
        whereArgs: [el["ID"]],
      );
      for (var songElement in songsQuery) {
        final song = songsById[songElement["SONG_ID"].toString()];
        if (song != null) songs.add(song);
      }

      rankingList.add(
        Ranking(el["ID"] as int, songs, el["RANKING_DATE"].toString()),
      );
    }
    return rankingList;
  }
}
