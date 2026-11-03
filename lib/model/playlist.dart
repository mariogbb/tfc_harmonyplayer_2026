import 'package:player/model/song.dart';

class PlaylistData {
  final List<SongData> songs;
  final int id;
  String name;

  PlaylistData({required this.songs, required this.name, required this.id});
}
