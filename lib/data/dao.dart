import 'dart:io';

import 'package:path/path.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';
import 'package:player/data/data.dart';
import 'package:player/model/playlist.dart';
import 'package:player/model/ranking.dart';
import 'package:player/model/song.dart';
import 'package:player/widgets/song_list.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class PlayerDatabase {
  static final PlayerDatabase _playerDatabase = PlayerDatabase.internal();

  // Databases
  late Database database;
  final PlayerData data = PlayerData();

  factory PlayerDatabase() {
    return _playerDatabase;
  }

  static PlayerDatabase get instance => _playerDatabase;

  Future initState() async {
    if (Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    database = await openDatabase(
      join(await getDatabasesPath(), "player_db.db"),
      onCreate: ((db, version) async {
        // Albums table
        await db.execute(
            "CREATE TABLE ALBUMS(ID INT UNSIGNED NOT NULL,URL TEXT NULL,PRIMARY KEY (ID))");
        // Artist table
        await db.execute(
            "CREATE TABLE ARTISTS(ID INT UNSIGNED NOT NULL,URL TEXT NULL,PRIMARY KEY (ID))");
        // Playlist table
        await db.execute(
            "CREATE TABLE PLAYLISTS(ID INTEGER PRIMARY KEY AUTOINCREMENT,PLAYLIST_NAME VARCHAR(50) NOT NULL)");
        await db
            .execute("CREATE UNIQUE INDEX AK_NAME ON PLAYLISTS(PLAYLIST_NAME)");
        // Songs table
        await db.execute(
            "CREATE TABLE SONGS(ID INT UNSIGNED, PLAYEDTIME INT UNSIGNED, PRIMARY KEY (ID))");
        // Playlist songs table
        await db.execute(
            "CREATE TABLE PLAYLIST_SONGS(SONG_ID INT UNSIGNED NOT NULL,PLAYLIST_ID INT UNSIGNED NOT NULL,FOREIGN KEY (PLAYLIST_ID) REFERENCES PLAYLISTS (ID) ON DELETE CASCADE ON UPDATE CASCADE)");
        // Liked songs playlist
        await db.insert("PLAYLISTS", {"PLAYLIST_NAME": "Liked songs"});
        // Rankings
        await db.execute(
            "CREATE TABLE RANKINGS(ID INTEGER PRIMARY KEY AUTOINCREMENT, RANKING_DATE VARCHAR(25), RANKING_TYPE INT UNSIGNED)");
        await db.execute(
            "CREATE TABLE RANKINGS_SONGS(SONG_ID INT UNSIGNED NOT NULL, RANKING_ID INT UNSIGNED NOT NULL,FOREIGN KEY (RANKING_ID) REFERENCES RANKINGS (ID) ON DELETE CASCADE ON UPDATE CASCADE)");
      }),
      version: 2,
    );
  }

  PlayerDatabase.internal();

  void saveAlbumArtwork(AlbumData album, String url) {
    try {
      database.insert("ALBUMS", {"ID": "${album.id}", "URL": url},
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {}
  }

  void saveArtistArtwork(ArtistData artist, String url) {
    try {
      database.insert("ARTISTS", {"ID": "${artist.id}", "URL": url},
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {}
  }

  Future<bool> findSongInDatabase(int id) async {
    bool out = false;

    try {
      List<Map> result = await database.query("SONGS",
          columns: ["ID"], where: "ID = ?", whereArgs: [id]);

      out = result.isNotEmpty;
    } catch (_) {}

    return out;
  }

  void addSongDuration(int id, Duration duration) async {
    try {
      Duration previousTime = await getSongPlayedTime(id);

      duration += previousTime;
      database.insert("SONGS", {"ID": id, "PLAYEDTIME": duration.inSeconds},
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {}
  }

  Future<Duration> getSongPlayedTime(int id) async {
    Duration out = Duration.zero;

    try {
      List<Map> result = await database.query("SONGS",
          columns: ["PLAYEDTIME"], where: "ID = ?", whereArgs: [id.toString()]);

      int seconds = result.first["PLAYEDTIME"];

      out = Duration(seconds: seconds);
    } catch (_) {}

    return out;
  }

  Future<String?> loadAlbumArtwork(AlbumData data) async {
    String? url;

    try {
      List<Map> result = await database.query("ALBUMS",
          columns: ["URL"], where: "ID = ?", whereArgs: [data.id.toString()]);

      if (result.first["URL"] != null) {
        url = result.first["URL"];
      }
    } catch (_) {}

    return url;
  }

  Future<String?> loadArtistUrl(ArtistData data) async {
    String? url;

    try {
      List<Map> result = await database.query("ARTISTS",
          columns: ["URL"], where: "ID = ?", whereArgs: [data.id.toString()]);

      if (result.first["URL"] != null) {
        url = result.first["URL"];
      }
    } catch (_) {}

    return url;
  }

  Future<List<Ranking>> loadRankings() async {
    List<Ranking> rankingList = [];

    try {
      List<Map> rankingQuery =
          await database.query("RANKINGS", columns: ["ID", "RANKING_DATE"]);

      for (var el in rankingQuery) {
        List<SongData> songs = [];

        List<Map> songsQuery = await database.query("RANKINGS_SONGS",
            columns: ["SONG_ID"],
            where: "RANKING_ID == ?",
            whereArgs: [el["ID"]]);
        for (var songElement in songsQuery) {
          try {
            SongData song = data.songList.firstWhere((dataElement) =>
                dataElement.id.toString() == songElement["SONG_ID"].toString());
            songs.add(song);
          } catch (_) {}
        }

        rankingList
            .add(Ranking(el["ID"], songs, el["RANKING_DATE"].toString()));
      }
    } catch (_) {}

    return rankingList;
  }

  // Playlists
  Future<List<PlaylistData>> loadPlaylists() async {
    List<PlaylistData> playlistList = [];

    try {
      List<Map> playlistQuery =
          await database.query("PLAYLISTS", columns: ["ID", "PLAYLIST_NAME"]);

      for (var element in playlistQuery) {
        List<SongData> songList = [];
        List<Map> songsQuery = await database.query("PLAYLIST_SONGS",
            columns: ["SONG_ID"],
            where: "PLAYLIST_ID == ?",
            whereArgs: [element["ID"]]);
        for (var songElement in songsQuery) {
          try {
            SongData song = data.songList.firstWhere((dataElement) =>
                dataElement.id.toString() == songElement["SONG_ID"].toString());
            songList.add(song);
          } catch (_) {}
        }

        playlistList.add(PlaylistData(
            id: element["ID"],
            songs: songList,
            name: element["PLAYLIST_NAME"].toString()));
      }
    } catch (_) {}

    return playlistList;
  }

  void addToPlaylist(PlaylistData playlist, SongData song) {
    try {
      database.insert("PLAYLIST_SONGS",
          {"SONG_ID": "${song.id}", "PLAYLIST_ID": playlist.id},
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {}
  }

  void removeFromPlaylist(PlaylistData playlist, SongData song) {
    try {
      database
          .rawDelete("DELETE FROM PLAYLIST_SONGS WHERE SONG_ID = ?", [song.id]);
    } catch (_) {}
  }

  Future<PlaylistData?> createPlaylist(String name) async {
    PlaylistData? playlist;

    try {
      int id = await database.insert("PLAYLISTS", {"PLAYLIST_NAME": name},
          conflictAlgorithm: ConflictAlgorithm.ignore);

      if (id > 0) {
        return PlaylistData(songs: [], name: name, id: id);
      }
    } catch (_) {}

    return playlist;
  }

  Future<void> removePlaylistFromDatabase(PlaylistData playlist) async {
    try {
      database.rawDelete("DELETE FROM PLAYLISTS WHERE ID = ?", [playlist.id]);
    } catch (_) {}
  }
}
