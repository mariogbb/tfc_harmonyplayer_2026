import 'dart:typed_data';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:player/model/artist.dart';
import 'package:player/data/data.dart';
import 'package:player/model/song.dart';

class AlbumData {
  final Uint8List artwork;
  String? imageURL;
  AlbumModel model;

  String get name => model.album;
  String get artist => model.artist.toString();
  int get id => model.id;
  ArtistData get artistData => _getArtist();
  List<SongData> get songList => _getSongs();
  Duration get duration => _getDuration();
  Duration get playedTime => _getPlayedTime();

  AlbumData(this.model, {required this.artwork, this.imageURL});

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
    return PlayerData().songList
        .where((element) => element.albumModel.id == model.id)
        .toList();
  }

  ArtistData _getArtist() {
    return PlayerData().artistList.firstWhere(
      (element) => element.id == model.artistId!,
    );
  }
}
