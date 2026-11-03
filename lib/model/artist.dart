import 'package:on_audio_query/on_audio_query.dart';
import 'package:player/model/album.dart';
import 'package:player/model/song.dart';

class ArtistData {
  ArtistModel model;
  String? imageURL;
  final List<AlbumData> _albums;
  final List<SongData> _songs;

  String get name => model.artist;
  int get id => model.id;
  List<SongData> get songList => _getSongs();
  List<AlbumData> get albumList => _getAlbums();
  Duration get duration => _getDuration();

  ArtistData(
    this.model, {
    required this._albums,
    required this._songs,
    this.imageURL,
  });

  Duration _getDuration() {
    Duration out = Duration.zero;

    for (SongData song in songList) {
      out += song.duration;
    }

    return out;
  }

  List<AlbumData> _getAlbums() {
    return _albums.where((element) => element.model.artistId == id).toList();
  }

  List<SongData> _getSongs() {
    return _songs.where((element) => element.model.artistId == id).toList();
  }
}
