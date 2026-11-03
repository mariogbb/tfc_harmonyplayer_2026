import 'package:flutter/material.dart';
import 'package:player/ui/playback/control_tab.dart';
import 'package:player/data/data.dart';
import 'package:player/model/album.dart';
import 'package:player/model/sort.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/model/top_recopilations.dart';
import 'package:player/ui/library/albums/album_list_item.dart';
import 'package:player/ui/core/control_padding.dart';

class TopAlbumsRanking extends StatefulWidget {
  const TopAlbumsRanking({Key? key}) : super(key: key);

  @override
  TopAlbumsRankingState createState() => TopAlbumsRankingState();
}

class TopAlbumsRankingState extends State<TopAlbumsRanking> {
  List<AlbumData> _getAlbumRanking(BuildContext context) {
    RankingData rankingType =
        ModalRoute.of(context)!.settings.arguments as RankingData;
    PlayerData data = PlayerData.instance;

    List<AlbumData> out = [];

    switch (rankingType.type) {
      case Ranking.allTime:
        List<AlbumData> list = List.from(data.albumList);
        AlbumSort sort = AlbumSort(
          ascendent: false,
          type: SortType.playingTime,
        );

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
    List<AlbumData> albumList = _getAlbumRanking(context);

    return SafeArea(
      top: true,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        bottomSheet: PlayerControlTab(),
        appBar: AppBar(actions: const [], title: const Text("")),
        body: ControlPadding(
          child: ListView(
            children: [
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.top_albums,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: const ClampingScrollPhysics(),
                itemCount: albumList.length,
                itemBuilder: (context, index) {
                  return AlbumListItem(
                    data: albumList[index],
                    ranking: (index + 1),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
