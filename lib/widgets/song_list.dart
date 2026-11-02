import 'package:flutter/widgets.dart';
import 'package:player/data/data.dart';
import 'package:player/model/play_context.dart';
import 'package:player/model/song.dart';
import 'package:player/model/sort.dart';
import 'package:player/widgets/song_list_item.dart';

class SongList extends StatelessWidget {
  final PlayingContext playingContext;
  final PlayerData playerData = PlayerData();
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final bool showArtistLabel;
  final bool showAlbum;
  final bool ranking;
  final Widget? leading;
  final SongSort? sort;

  int get songCount => playingContext.getSongs.length;
  Duration get totalDuration => _calculateDuration();

  SongList(
      {Key? key,
      required this.playingContext,
      this.ranking = false,
      this.physics,
      this.shrinkWrap = false,
      this.showArtistLabel = true,
      this.showAlbum = false,
      this.leading,
      this.sort})
      : super(key: key);

  Duration _calculateDuration() {
    Duration out = Duration.zero;

    for (var element in playingContext.getSongs) {
      out += Duration(milliseconds: element.model.duration!);
    }

    return out;
  }

  void play(SongData data) {
    playerData.handler
        .playSongList(playingContext, playingContext.getSongs.indexOf(data));
  }

  @override
  Widget build(BuildContext context) {
    SongSort finalSort;
    List<SongData> finalSongList = List.from(playingContext.getSongs);

    if (sort == null) {
      finalSort = SongSort();
    } else {
      finalSort = sort!;
    }

    finalSongList.sort(finalSort.sort);

    return ListView.builder(
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount:
          (leading == null) ? finalSongList.length : finalSongList.length + 1,
      itemBuilder: (context, index) {
        if (leading != null && index == 0) {
          return leading!;
        }

        int songIndex = (leading == null) ? index : index - 1;

        return SongListItem(
          showArtistLabel: showArtistLabel,
          showAlbum: showAlbum,
          ranking: (ranking) ? index + 1 : -1,
          data: finalSongList[songIndex],
          play: play,
        );
      },
    );
  }
}
