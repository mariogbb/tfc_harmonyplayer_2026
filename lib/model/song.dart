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
  String get artist => model.artist ?? 'Unknown artist';
  String get album => model.album ?? 'Unknown album';
  int get id => model.id;
  int get trackNum => (model.track ?? 0) % 1000;
  Duration get duration => Duration(milliseconds: model.duration ?? 0);
  Uint8List get artwork => albumModel.artwork;
  ArtistData get artistModel => _getArtist();

  SongData({
    required this.model,
    required this.albumModel,
    required this.playedTime,
    required this._artists,
  });

  ArtistData _getArtist() {
    return _artists.firstWhere(
      (element) => element.id == model.artistId,
      orElse: () => ArtistData(
        ArtistMetadata(
          id: model.artistId ?? -1,
          artist: model.artist ?? 'Unknown artist',
        ),
        albums: [albumModel],
        songs: albumModel.songList,
      ),
    );
  }
}
