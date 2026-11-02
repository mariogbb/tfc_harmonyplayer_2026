import 'dart:convert';
import 'dart:io';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:http/http.dart' as http;
import 'package:player/model/album.dart';
import 'package:player/data/data.dart';
import 'package:player/data/dao.dart';
import 'package:player/model/song.dart';

class ArtistData {
  ArtistModel model;
  String? _imageUrl;

  PlayerDatabase database = PlayerDatabase.instance;

  String get name => model.artist;
  String? get imageURL => _imageUrl;
  int get id => model.id;
  List<SongData> get songList => _getSongs();
  List<AlbumData> get albumList => _getAlbums();
  Duration get duration => _getDuration();

  ArtistData(this.model) {
    _loadImageUrl();
  }

  Duration _getDuration() {
    Duration out = Duration.zero;

    for (SongData song in songList) {
      out += song.duration;
    }

    return out;
  }

  List<AlbumData> _getAlbums() {
    return PlayerData()
        .albumList
        .where((element) => element.model.artistId! == id)
        .toList();
  }

  List<SongData> _getSongs() {
    return PlayerData()
        .songList
        .where((element) => element.model.artistId! == id)
        .toList();
  }

  void _loadImageUrl() async {
    _imageUrl = await database.loadArtistUrl(this);

    if (_imageUrl == null) {
      var uri =
          Uri.parse('https://api.deezer.com/search/artist?q=${model.artist}');

      var headers = {HttpHeaders.contentTypeHeader: "application/json"};

      try {
        http.Response response = await http.get(uri, headers: headers);
        final parsed = json.decode(response.body);

        var strings = parsed["data"];
        _imageUrl = strings[0]["picture_xl"];

        if (_imageUrl != null) {
          database.saveArtistArtwork(this, _imageUrl!);
        }
      } catch (_) {}
    }
  }
}
