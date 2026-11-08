import 'package:flutter/material.dart';
import 'package:player/data/settings.dart';
import 'package:provider/provider.dart';
import 'package:player/data/data.dart';
import 'package:player/ui/library/songs/song_dialogs.dart';
import 'package:player/model/album.dart';
import 'package:player/ui/core/generic_artwork.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/ui/core/library_row.dart';
import 'package:player/ui/library/library_controller.dart';

class AlbumListItem extends StatelessWidget {
  const AlbumListItem({Key? key, required this.data, this.ranking = -1})
    : super(key: key);

  final AlbumData data;
  final int ranking;

  List<PopupMenuItem<int>> _contextualOptions(BuildContext context) {
    return [
      PopupMenuItem<int>(
        value: 1,
        child: ListTile(
          leading: Icon(
            Icons.format_list_bulleted_add,
            color: Theme.of(context).primaryColor,
          ),
          title: Text(
            AppLocalizations.of(context)!.add_to_playlist,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ),
      PopupMenuItem<int>(
        value: 2,
        child: ListTile(
          leading: Icon(Icons.queue, color: Theme.of(context).primaryColor),
          title: Text(
            AppLocalizations.of(context)!.add_to_queue,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ),
      PopupMenuItem<int>(
        value: 3,
        child: ListTile(
          leading: Icon(
            Icons.person_pin,
            color: Theme.of(context).primaryColor,
          ),
          title: Text(
            AppLocalizations.of(context)!.open_artist,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LibraryController?>();
    ArtworkShape shape = ArtworkShape.square;

    int? index = context.watch<PlayerSettings>().store.read<int>(
      "albumtab_artwork_shape",
    );

    if (index != null && index >= 0 && index < ArtworkShape.values.length) {
      shape = ArtworkShape.values[index];
    }

    return LibraryRow(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.pushNamed(context, "album", arguments: data);
        },
        child: ListTile(
          leading: (ranking != -1)
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Text(
                        "$ranking",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    GenericArtwork(
                      artwork: data.artwork,
                      imageUrl: data.imageURL,
                      elementId: data.id,
                      shape: shape,
                      type: ArtworkType.album,
                    ),
                  ],
                )
              : GenericArtwork(
                  artwork: data.artwork,
                  imageUrl: data.imageURL,
                  elementId: data.id,
                  shape: shape,
                  type: ArtworkType.album,
                ),
          title: Text(data.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            data.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: PopupMenuButton<int>(
            elevation: 5,
            itemBuilder: (context) {
              return _contextualOptions(context);
            },
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 1:
                  SongDialogs.addAlbumToPlaylistDialog(data, context);
                  break;
                case 2:
                  PlayerData.instance.handler.addAlbumToQueue(data);
                  break;
                case 3:
                  Navigator.pushNamed(
                    context,
                    "artist",
                    arguments: data.artistData,
                  );
                  break;
              }
            },
          ),
        ),
      ),
    );
  }
}
