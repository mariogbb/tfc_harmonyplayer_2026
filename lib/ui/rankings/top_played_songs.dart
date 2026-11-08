import 'package:flutter/material.dart';
import 'package:player/ui/playback/control_tab.dart';
import 'package:player/ui/library/library_controller.dart';
import 'package:provider/provider.dart';
import 'package:player/model/play_context.dart';
import 'package:player/model/song.dart';
import 'package:player/model/sort.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/model/top_recopilations.dart';
import 'package:player/ui/core/control_padding.dart';
import 'package:player/ui/library/songs/song_list.dart';
import 'package:player/ui/core/desktop_content_scope.dart';

class TopSongsRanking extends StatefulWidget {
  const TopSongsRanking({Key? key}) : super(key: key);

  @override
  TopSongsRankingState createState() => TopSongsRankingState();
}

class TopSongsRankingState extends State<TopSongsRanking> {
  List<SongData> _getSongRanking(BuildContext context) {
    RankingData rankingType =
        ModalRoute.of(context)!.settings.arguments as RankingData;
    final data = context.watch<LibraryController>();

    List<SongData> out = [];

    switch (rankingType.type) {
      case Ranking.allTime:
        List<SongData> list = List.from(data.songList);
        SongSort sort = SongSort(ascendent: false, type: SortType.playingTime);

        list.sort(sort.sort);

        if (list.length > 100) {
          list.removeRange(100, list.length);
        }

        list.forEach(out.add);

        break;
      case Ranking.lastMonth:
        // TODO: Handle this case.
        break;
      case Ranking.monthRange:
        // TODO: Handle this case.
        break;
      case Ranking.lastYear:
        // TODO: Handle this case.
        break;
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    List<SongData> songList = _getSongRanking(context);

    return SafeArea(
      top: true,
      child: Scaffold(
        bottomSheet: DesktopContentScope.isActive(context)
            ? null
            : PlayerControlTab(),
        appBar: DesktopContentScope.isActive(context)
            ? null
            : AppBar(title: Text(AppLocalizations.of(context)!.top_songs)),
        body: ControlPadding(
          child: ListView(
            children: [
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.top_songs,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              SongList(
                playingContext: PlayingContext(
                  AppLocalizations.of(context)!.top_played_songs,
                  ContextType.topPlayedSongs,
                  songList,
                ),
                ranking: true,
                sort: SongSort(type: SortType.playingTime, ascendent: false),
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
