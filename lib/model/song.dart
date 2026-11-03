import 'dart:typed_data';

import 'package:player/model/library_metadata.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';

class SongData {
  final SongMetadata model;
  final AlbumData albumModel;
  final List<ArtistData> _artists;
  Duration playedTime;

  String get title => model.title;
  String get artist => model.artist.toString();
  String get album => model.album.toString();
  int get id => model.id;
  int get trackNum => (model.track! % 1000).toInt();
  Duration get duration => Duration(milliseconds: model.duration!);
  Uint8List get artwork => albumModel.artwork;
  ArtistData get artistModel => _getArtist();

  SongData({
    required this.model,
    required this.albumModel,
    required this.playedTime,
    required this._artists,
  });

  ArtistData _getArtist() {
    return _artists.firstWhere((element) => element.id == model.artistId!);
  }
}
