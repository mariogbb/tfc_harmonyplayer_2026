import 'package:flutter/material.dart';
import 'package:player/data/data.dart';
import 'package:player/dialogs/playlist_dialogs.dart';
import 'package:player/widgets/playlist_list_item.dart';
import 'package:provider/provider.dart';
import 'package:player/l10n/app_localizations.dart';

class PlaylistTab extends StatelessWidget {
  const PlaylistTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerData>(
      builder: (context, value, child) {
        if (value.playlists.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.no_playlist_found),
          );
        }

        return ListView.builder(
          itemCount: value.playlists.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(top: 50),
                child: ListTile(
                  title: Row(
                    verticalDirection: VerticalDirection.down,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.playlist_tab,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        " (${value.playlists.length})",
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () =>
                        PlaylistDialogs.createPlaylistPopup(context),
                    icon: const Icon(
                      Icons.playlist_add,
                    ),
                  ),
                ),
              );
            }

            return GestureDetector(
              onTap: () => Navigator.pushNamed(context, "playlist",
                  arguments: value.playlists[index - 1]),
              child: PlaylistItem(playlist: value.playlists[index - 1]),
            );
          },
        );
      },
    );
  }
}
