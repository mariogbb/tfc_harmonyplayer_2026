import 'package:flutter/material.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/model/album.dart';
import 'package:player/model/playlist.dart';
import 'package:player/model/song.dart';

import 'package:player/ui/playlists/playlist_controller.dart';
import 'package:provider/provider.dart';

class SongDialogs {
  static void addToPlaylistDialog(SongData song, BuildContext context) {
    final data = context.read<PlaylistController>();
    List<PlaylistData> playlists = data.playlists;

    final List<PlaylistData> playlistToAdd = [];

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.add_to_playlist,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    trailing: OutlinedButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      onPressed: () {
                        for (var element in playlistToAdd) {
                          data.addSong(element, song);
                        }
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context)!.add),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (playlistToAdd.contains(playlists[index])) {
                              playlistToAdd.remove(playlists[index]);
                            } else {
                              playlistToAdd.add(playlists[index]);
                            }
                          });
                        },
                        child: ListTile(
                          tileColor: (playlistToAdd.contains(playlists[index]))
                              ? Colors.blue.shade500
                              : null,
                          title: Text(playlists[index].name),
                          subtitle: Text(
                            "${playlists[index].songs.length} ${AppLocalizations.of(context)!.plural_songs}",
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void addAlbumToPlaylistDialog(AlbumData album, BuildContext context) {
    final data = context.read<PlaylistController>();
    List<PlaylistData> playlists = data.playlists;

    final List<PlaylistData> playlistToAdd = [];

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.add_to_playlist,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    trailing: OutlinedButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      onPressed: () {
                        for (var element in playlistToAdd) {
                          for (var song in album.songList) {
                            data.addSong(element, song);
                          }
                        }
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context)!.add),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (playlistToAdd.contains(playlists[index])) {
                              playlistToAdd.remove(playlists[index]);
                            } else {
                              playlistToAdd.add(playlists[index]);
                            }
                          });
                        },
                        child: ListTile(
                          tileColor: (playlistToAdd.contains(playlists[index]))
                              ? Colors.blue.shade500
                              : null,
                          title: Text(playlists[index].name),
                          subtitle: Text(
                            "${playlists[index].songs.length} ${AppLocalizations.of(context)!.plural_songs}",
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
