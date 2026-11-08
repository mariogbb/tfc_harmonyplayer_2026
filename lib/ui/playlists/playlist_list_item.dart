import 'package:flutter/material.dart';
import 'package:player/ui/playlists/playlist_controller.dart';
import 'package:player/ui/playlists/playlist_dialogs.dart';
import 'package:provider/provider.dart';
import 'package:player/model/playlist.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/ui/core/library_row.dart';
import 'package:player/theme_data/neo_style.dart';

class PlaylistItem extends StatelessWidget {
  final PlaylistData playlist;

  const PlaylistItem({Key? key, required this.playlist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LibraryRow(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: NeoStyle.control(context, radius: 13),
          child: Icon(
            Icons.queue_music_rounded,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          playlist.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text("${playlist.songs.length} songs"),
        trailing: PopupMenuButton<int>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) {
            return [
              PopupMenuItem<int>(
                value: 1,
                enabled: playlist.id != 1,
                child: ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.delete_playlist,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: (playlist.id != 1)
                          ? null
                          : Theme.of(context).disabledColor,
                    ),
                  ),
                  leading: Icon(
                    Icons.delete,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              PopupMenuItem<int>(
                value: 2,
                child: ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.rename_playlist,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  leading: Icon(
                    Icons.drive_file_rename_outline,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ];
          },
          onSelected: (value) {
            switch (value) {
              case 1:
                context.read<PlaylistController>().delete(playlist);
                break;

              case 2:
                PlaylistDialogs.renamePlaylist(context, playlist);
                break;
            }
          },
        ),
      ),
    );
  }
}
