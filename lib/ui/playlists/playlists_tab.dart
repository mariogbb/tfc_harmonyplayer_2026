import 'package:flutter/material.dart';
import 'package:player/ui/playlists/playlist_controller.dart';
import 'package:player/ui/playlists/playlist_dialogs.dart';
import 'package:player/ui/playlists/playlist_list_item.dart';
import 'package:player/ui/core/library_header.dart';
import 'package:provider/provider.dart';
import 'package:player/l10n/app_localizations.dart';

class PlaylistTab extends StatelessWidget {
  const PlaylistTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistController>(
      builder: (context, value, child) {
        if (value.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (value.error != null) {
          return Center(
            child: Text(AppLocalizations.of(context)!.playlist_load_error),
          );
        }
        if (value.playlists.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.no_playlist_found),
          );
        }

        return ListView.builder(
          itemCount: value.playlists.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return LibraryHeader(
                title: AppLocalizations.of(context)!.playlist_tab,
                count: value.playlists.length,
                actions: [
                  IconButton(
                    onPressed: () =>
                        PlaylistDialogs.createPlaylistPopup(context),
                    icon: const Icon(Icons.playlist_add),
                  ),
                ],
              );
            }

            return GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                "playlist",
                arguments: value.playlists[index - 1],
              ),
              child: PlaylistItem(playlist: value.playlists[index - 1]),
            );
          },
        );
      },
    );
  }
}
