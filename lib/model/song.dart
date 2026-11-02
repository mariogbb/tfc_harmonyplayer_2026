import 'dart:typed_data';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';
import 'package:player/data/data.dart';

class SongData {
  final SongModel model;
  final AlbumData albumModel;
  final PlayerData playerData = PlayerData();
  Duration playedTime;

  String get title => model.title;
  String get artist => model.artist.toString();
  String get album => model.album.toString();
  int get id => model.id;
  int get trackNum => (model.track! % 1000).toInt();
  Duration get duration => Duration(milliseconds: model.duration!);
  Uint8List get artwork => albumModel.artwork;
  ArtistData get artistModel => _getArtist();

  SongData(
      {required this.model,
      required this.albumModel,
      required this.playedTime});

  ArtistData _getArtist() {
    return playerData.artistList
        .firstWhere((element) => element.id == model.artistId!);
  }
}
