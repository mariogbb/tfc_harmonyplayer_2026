import 'package:flutter/material.dart';
import 'package:player/data/data.dart';
import 'package:player/model/play_context.dart';
import 'package:player/widgets/song_list.dart';
import 'package:player/model/sort.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class PlayerSongsTab extends StatefulWidget {
  const PlayerSongsTab({Key? key}) : super(key: key);

  @override
  PlayerSongsTabState createState() => PlayerSongsTabState();
}

class PlayerSongsTabState extends State<PlayerSongsTab> {
  bool ascendant = true;

  SortType selectedSort = SortType.alphabetical;

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerData>(
      builder: (context, value, child) {
        if (value.songList.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.no_song_found),
          );
        }

        return SongList(
          playingContext: PlayingContext(
              AppLocalizations.of(context)!.all_songs,
              ContextType.allSongs,
              value.songList),
          sort: SongSort(type: selectedSort, ascendent: ascendant),
          leading: Padding(
            padding: const EdgeInsets.only(top: 50),
            child: ListTile(
              leading: Row(
                verticalDirection: VerticalDirection.down,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.songs_tab,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    " (${value.songList.length})",
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PopupMenuButton<SortType>(
                    onSelected: (value) {
                      setState(() {
                        selectedSort = value;
                      });
                    },
                    initialValue: SortType.alphabetical,
                    itemBuilder: (context) => <PopupMenuEntry<SortType>>[
                      PopupMenuItem<SortType>(
                        value: SortType.alphabetical,
                        child: Text(AppLocalizations.of(context)!.title),
                      ),
                      PopupMenuItem<SortType>(
                        value: SortType.album,
                        child: Text(AppLocalizations.of(context)!.album),
                      ),
                    ],
                    child: Icon(
                      Icons.sort,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        ascendant = !ascendant;
                      });
                    },
                    icon: Icon(
                      (ascendant)
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
