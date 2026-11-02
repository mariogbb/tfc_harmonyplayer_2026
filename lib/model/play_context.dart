import 'package:player/model/song.dart';

class PlayingContext {
  final String _name;
  final ContextType _type;
  final List<SongData> _songs;

  PlayingContext(this._name, this._type, this._songs);

  String get getName => _name;
  ContextType get getContext => _type;
  List<SongData> get getSongs => _songs;
}

enum ContextType {
  album,
  song,
  playlist,
  artist,
  allSongs,
  topPlayedAlbums,
  topPlayedSongs
}
