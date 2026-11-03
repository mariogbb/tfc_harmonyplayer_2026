import 'package:flutter/material.dart';
import 'package:player/data/data.dart';
import 'package:player/model/playlist.dart';
import 'package:player/l10n/app_localizations.dart';

class PlaylistItem extends StatelessWidget {
  final PlaylistData playlist;

  const PlaylistItem({Key? key, required this.playlist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(playlist.name),
      subtitle: Text("${playlist.songs.length} songs"),
      trailing: PopupMenuButton<int>(
        icon: const Icon(Icons.more_vert),
        itemBuilder: (context) {
          return [
            PopupMenuItem<int>(
              value: 1,
              enabled: (playlist.name != "Liked songs"),
              child: ListTile(
                title: Text(
                  AppLocalizations.of(context)!.delete_playlist,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: (playlist.name != "Liked songs")
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
              PlayerData.instance.deletePlaylist(playlist);
              break;

            case 2:
              break;

            case 3:
              break;

            case 4:
              break;
          }
        },
      ),
    );
  }
}
