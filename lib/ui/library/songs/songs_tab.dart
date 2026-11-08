import 'package:flutter/material.dart';
import 'package:player/ui/library/library_controller.dart';
import 'package:player/model/play_context.dart';
import 'package:player/ui/library/songs/song_list.dart';
import 'package:player/model/sort.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:player/ui/core/library_header.dart';

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
    return Consumer<LibraryController>(
      builder: (context, value, child) {
        if (value.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (value.error != null) {
          return Center(
            child: Text(
              value.isPermissionDenied
                  ? AppLocalizations.of(context)!.library_permission_error
                  : AppLocalizations.of(context)!.library_load_error,
            ),
          );
        }
        if (value.songList.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.no_song_found),
          );
        }

        return SongList(
          playingContext: PlayingContext(
            AppLocalizations.of(context)!.all_songs,
            ContextType.allSongs,
            value.songList,
          ),
          sort: SongSort(type: selectedSort, ascendent: ascendant),
          leading: LibraryHeader(
            title: AppLocalizations.of(context)!.songs_tab,
            count: value.songList.length,
            actions: [
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
        );
      },
    );
  }
}
