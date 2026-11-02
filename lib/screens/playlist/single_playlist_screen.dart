import 'package:flutter/material.dart';
import 'package:player/control/control_tab.dart';
import 'package:player/model/play_context.dart';
import 'package:player/model/playlist.dart';
import 'package:player/model/song.dart';
import 'package:player/model/sort.dart';
import 'package:player/widgets/control_padding.dart';
import 'package:player/widgets/song_list.dart';

class SinglePlaylistScreen extends StatefulWidget {
  const SinglePlaylistScreen({Key? key}) : super(key: key);

  @override
  SinglePlaylistScreenState createState() => SinglePlaylistScreenState();
}

class SinglePlaylistScreenState extends State<SinglePlaylistScreen> {
  @override
  Widget build(BuildContext context) {
    PlaylistData playlist =
        ModalRoute.of(context)!.settings.arguments as PlaylistData;
    List<SongData> songs = playlist.songs;

    return SafeArea(
      top: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(playlist.name),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        extendBodyBehindAppBar: true,
        bottomSheet: PlayerControlTab(),
        body: ControlPadding(
          child: SongList(
            playingContext:
                PlayingContext(playlist.name, ContextType.playlist, songs),
            sort: SongSort(type: SortType.none),
            leading: ListTile(
              title: Text(
                playlist.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
