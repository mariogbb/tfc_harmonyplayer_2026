import 'package:flutter/material.dart';
import 'package:player/ui/playback/control_tab.dart';
import 'package:player/ui/library/library_controller.dart';
import 'package:provider/provider.dart';
import 'package:player/model/album.dart';
import 'package:player/model/sort.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/model/top_recopilations.dart';
import 'package:player/ui/library/albums/album_list_item.dart';
import 'package:player/ui/core/control_padding.dart';
import 'package:player/ui/core/desktop_content_scope.dart';

class TopAlbumsRanking extends StatefulWidget {
  const TopAlbumsRanking({Key? key}) : super(key: key);

  @override
  TopAlbumsRankingState createState() => TopAlbumsRankingState();
}

class TopAlbumsRankingState extends State<TopAlbumsRanking> {
  List<AlbumData> _getAlbumRanking(BuildContext context) {
    RankingData rankingType =
        ModalRoute.of(context)!.settings.arguments as RankingData;
    final data = context.watch<LibraryController>();

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
        bottomSheet: DesktopContentScope.isActive(context)
            ? null
            : PlayerControlTab(),
        appBar: DesktopContentScope.isActive(context)
            ? null
            : AppBar(title: Text(AppLocalizations.of(context)!.top_albums)),
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
