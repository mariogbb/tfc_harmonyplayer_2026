import 'package:player/data/dao.dart';
import 'package:player/model/song.dart';

class PlaylistData {
  final List<SongData> songs;
  final int id;
  String name;

  PlaylistData({required this.songs, required this.name, required this.id});

  void addSong(SongData data) {
    PlayerDatabase database = PlayerDatabase.instance;

    if (!songs.contains(data)) {
      songs.add(data);
      database.addToPlaylist(this, data);
    }
  }

  void removeSong(SongData data) {
    PlayerDatabase database = PlayerDatabase();

    if (songs.contains(data)) {
      songs.remove(data);
      database.removeFromPlaylist(this, data);
    }
  }
}
