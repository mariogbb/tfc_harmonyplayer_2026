import 'dart:typed_data';

import 'package:player/model/library_metadata.dart';
import 'package:player/model/artist.dart';
import 'package:player/model/song.dart';

class AlbumData {
  final Uint8List artwork;
  String? imageURL;
  final AlbumMetadata model;
  final List<SongData> _songs;
  final List<ArtistData> _artists;

  String get name => model.album;
  String get artist => model.artist.toString();
  int get id => model.id;
  ArtistData get artistData => _getArtist();
  List<SongData> get songList => _getSongs();
  Duration get duration => _getDuration();
  Duration get playedTime => _getPlayedTime();

  AlbumData(
    this.model, {
    required this.artwork,
    required this._songs,
    required this._artists,
    this.imageURL,
  });

  Duration _getPlayedTime() {
    Duration out = Duration.zero;

    for (var element in songList) {
      out += element.playedTime;
    }

    return out;
  }

  Duration _getDuration() {
    Duration out = Duration.zero;

    for (SongData song in songList) {
      out += song.duration;
    }

    return out;
  }

  List<SongData> _getSongs() {
    return _songs
        .where((element) => element.albumModel.id == model.id)
        .toList();
  }

  ArtistData _getArtist() {
    return _artists.firstWhere(
      (element) => element.id == model.artistId,
      orElse: () => ArtistData(
        ArtistMetadata(
          id: model.artistId ?? -1,
          artist: model.artist ?? 'Unknown artist',
        ),
        albums: [this],
        songs: _songs,
      ),
    );
  }
}
