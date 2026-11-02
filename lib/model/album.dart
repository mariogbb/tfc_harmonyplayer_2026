import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:http/http.dart' as http;
import 'package:player/model/artist.dart';
import 'package:player/data/data.dart';
import 'package:player/data/dao.dart';
import 'package:player/model/song.dart';

class AlbumData {
  late Uint8List artwork;
  String? _imageUrl;
  AlbumModel model;

  PlayerDatabase database = PlayerDatabase.instance;

  String get name => model.album;
  String get artist => model.artist.toString();
  String? get imageURL => _imageUrl;
  int get id => model.id;
  ArtistData get artistData => _getArtist();
  List<SongData> get songList => _getSongs();
  Duration get duration => _getDuration();
  Duration get playedTime => _getPlayedTime();

  AlbumData(this.model) {
    _loadArtwork();
    _loadHDArtwork();
  }

  void _loadHDArtwork() async {
    _imageUrl = await database.loadAlbumArtwork(this);

    if (_imageUrl == null) {
      try {
        var uri = Uri.parse('https://api.deezer.com/search/album?q=$name');

        var headers = {HttpHeaders.contentTypeHeader: "application/json"};

        http.Response response = await http.get(uri, headers: headers);
        final parsed = json.decode(response.body);

        var strings = parsed["data"];
        _imageUrl = strings[0]["cover_xl"];

        if (_imageUrl != null) {
          database.saveAlbumArtwork(this, _imageUrl!);
        }
      } catch (_) {
        _imageUrl = null;
      }
    }
  }

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

  void _loadArtwork() async {
    OnAudioQuery query = OnAudioQuery();

    Uint8List? buffer = await query.queryArtwork(id, ArtworkType.ALBUM,
        format: ArtworkFormat.PNG);

    if (buffer == null) {
      var a = await rootBundle.load("assets/no_artwork_icon.png");

      buffer = a.buffer.asUint8List();
    }

    artwork = buffer;
  }

  List<SongData> _getSongs() {
    return PlayerData()
        .songList
        .where((element) => element.albumModel.id == model.id)
        .toList();
  }

  ArtistData _getArtist() {
    return PlayerData()
        .artistList
        .firstWhere((element) => element.id == model.artistId!);
  }
}
