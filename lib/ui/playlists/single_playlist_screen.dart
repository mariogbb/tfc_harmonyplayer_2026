import 'package:flutter/material.dart';
import 'package:player/data/data.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/model/play_context.dart';
import 'package:player/model/playlist.dart';
import 'package:player/model/sort.dart';
import 'package:player/ui/core/control_padding.dart';
import 'package:player/ui/core/desktop_content_scope.dart';
import 'package:player/ui/core/detail_header.dart';
import 'package:player/ui/core/neo_action_button.dart';
import 'package:player/ui/library/songs/song_list.dart';
import 'package:player/ui/playback/control_tab.dart';

class SinglePlaylistScreen extends StatelessWidget {
  const SinglePlaylistScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final playlist = ModalRoute.of(context)!.settings.arguments as PlaylistData;
    final songs = playlist.songs;
    final labels = AppLocalizations.of(context)!;
    return SafeArea(
      child: Scaffold(
        appBar: DesktopContentScope.isActive(context)
            ? null
            : AppBar(
                title: Text(
                  playlist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
        bottomSheet: DesktopContentScope.isActive(context)
            ? null
            : PlayerControlTab(),
        body: ControlPadding(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: SongList(
                playingContext: PlayingContext(
                  playlist.name,
                  ContextType.playlist,
                  songs,
                ),
                sort: SongSort(type: SortType.none),
                leading: Column(
                  children: [
                    DetailHeader(
                      title: playlist.name,
                      subtitle: '${songs.length} ${labels.plural_songs}',
                      artwork: ColoredBox(
                        color: Theme.of(context).primaryColor
                            .withValues(alpha: 0.14),
                        child: Icon(
                          Icons.queue_music_rounded,
                          size: 80,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      action: NeoActionButton(
                        onPressed: songs.isEmpty
                            ? null
                            : () => PlayerData.instance.handler.playSongList(
                                PlayingContext(
                                  playlist.name,
                                  ContextType.playlist,
                                  songs,
                                ),
                                0,
                              ),
                        icon: Icons.play_arrow_rounded,
                        label: labels.play_all,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        labels.plural_songs,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      trailing: Text('${songs.length}'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
