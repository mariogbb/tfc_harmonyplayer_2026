import 'package:player/model/album.dart';
import 'package:player/model/song.dart';

class SongSort {
  SortType type = SortType.alphabetical;
  bool ascendent;

  SongSort({this.type = SortType.alphabetical, this.ascendent = true});

  int sort(SongData a, SongData b) {
    int out;

    switch (type) {
      case SortType.alphabetical:
        out = a.title.compareTo(b.title);
        break;
      case SortType.trackNumber:
        if (a.model.track == null || b.model.track == null) {
          out = 1;
        } else {
          out = a.trackNum.compareTo(b.trackNum);
        }
        break;
      case SortType.album:
        out = a.album.compareTo(b.album);

        if (out == 0) {
          out = a.title.compareTo(b.title);
        }

        break;
      case SortType.playingTime:
        out = a.playedTime.compareTo(b.playedTime);
        break;
      case SortType.none:
        out = 0;
        break;
    }

    if (!ascendent) {
      out = -out;
    }

    return out;
  }
}

class AlbumSort {
  SortType type = SortType.alphabetical;
  bool ascendent;

  AlbumSort({this.type = SortType.alphabetical, this.ascendent = true});

  int sort(AlbumData a, AlbumData b) {
    int out;

    switch (type) {
      case SortType.alphabetical:
        out = a.name.compareTo(b.name);

        break;
      case SortType.trackNumber:
        out = a.songList.length.compareTo(b.songList.length);

        break;
      case SortType.album:
        out = a.name.compareTo(b.name);

        break;
      case SortType.playingTime:
        out = a.playedTime.compareTo(b.playedTime);
        break;
      case SortType.none:
        out = 0;
        break;
    }

    if (!ascendent) {
      out = -out;
    }

    return out;
  }
}

enum SortType { alphabetical, trackNumber, album, playingTime, none }
