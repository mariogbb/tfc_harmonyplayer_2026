import 'package:flutter/material.dart';
import 'package:player/control/media_control.dart';
import 'package:player/data/data.dart';
import 'package:player/data/settings.dart';
import 'package:player/ui/library/songs/song_dialogs.dart';
import 'package:player/model/song.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/utils/extensions.dart';
import 'package:player/ui/core/generic_artwork.dart';
import 'package:provider/provider.dart';
import 'package:player/ui/core/library_row.dart';
import 'package:player/ui/library/library_controller.dart';

class SongListItem extends StatefulWidget {
  final SongData data;
  final ValueChanged<SongData> play;
  final PlayerData playerData = PlayerData();
  final PlayerHandler handler = PlayerData.instance.handler;

  final bool showArtistLabel;
  final bool showAlbum;
  final int ranking;

  SongListItem({
    Key? key,
    required this.data,
    required this.play,
    this.ranking = -1,
    this.showArtistLabel = true,
    this.showAlbum = false,
  }) : super(key: key);

  @override
  SongListItemState createState() => SongListItemState();
}

class SongListItemState extends State<SongListItem> {
  final bool _playing = false; // TODO: future to check if a song is playing and highlight in case it is

  List<PopupMenuItem<int>> _contextualOptions() {
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
          leading: Icon(
            Icons.play_lesson,
            color: Theme.of(context).primaryColor,
          ),
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
      PopupMenuItem<int>(
        value: 4,
        child: ListTile(
          leading: Icon(
            Icons.album_rounded,
            color: Theme.of(context).primaryColor,
          ),
          title: Text(
            AppLocalizations.of(context)!.open_album,
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
      "song_artwork_shape",
    );

    if (index != null && index >= 0 && index < ArtworkShape.values.length) {
      shape = ArtworkShape.values[index];
    }

    return LibraryRow(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: (() => {widget.play(widget.data)}),
        child: ListTile(
          leading: (widget.ranking != -1)
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Text(
                        "${widget.ranking}",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    GenericArtwork(
                      type: ArtworkType.song,
                      shape: shape,
                      elementId: widget.data.id,
                      artwork: widget.data.artwork,
                      imageUrl: widget.data.albumModel.imageURL,
                    ),
                  ],
                )
              : (widget.showAlbum)
              ? Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(widget.data.trackNum.toString()),
                )
              : GenericArtwork(
                  type: ArtworkType.song,
                  shape: shape,
                  elementId: widget.data.id,
                  artwork: widget.data.artwork,
                  imageUrl: widget.data.albumModel.imageURL,
                ),
          title: Text(
            widget.data.title,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: (_playing) ? Theme.of(context).primaryColor : null,
            ),
          ),
          subtitle: (widget.showArtistLabel)
              ? Text(
                  widget.data.artist,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: (_playing)
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).unselectedWidgetColor,
                  ),
                )
              : null,
          trailing: Consumer<PlayerSettings>(
            builder: (context, value, child) {
              Widget popup = PopupMenuButton<int>(
                elevation: 5,
                itemBuilder: (context) {
                  return _contextualOptions();
                },
                onSelected: (value) {
                  switch (value) {
                    case 1:
                      SongDialogs.addToPlaylistDialog(widget.data, context);
                      break;

                    case 2:
                      widget.handler.addToQueue(widget.data);
                      break;

                    case 3:
                      Navigator.of(
                        context,
                      ).pushNamed('artist', arguments: widget.data.artistModel);
                      break;

                    case 4:
                      Navigator.pushNamed(
                        context,
                        "album",
                        arguments: widget.data.albumModel,
                      );
                      break;
                  }
                },
                icon: const Icon(Icons.more_vert),
              );

              if (value.isShowSongTimeLabel) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(widget.data.duration.toStringRepresentation()),
                    popup,
                  ],
                );
              }

              return popup;
            },
          ),
        ),
      ),
    );
  }
}
