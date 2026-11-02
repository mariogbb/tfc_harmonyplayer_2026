import 'package:player/model/song.dart';
import 'package:player/model/top_recopilations.dart';

class Ranking {
  late DateTime date;
  late List<SongData> _songs;
  late RankingData data;
  late int id;

  List<SongData> get getSongs => _songs;

  Ranking(int id, List<SongData> songs, String stringDate) {
    _songs = songs;
    date = DateTime.parse(stringDate);
  }
}
