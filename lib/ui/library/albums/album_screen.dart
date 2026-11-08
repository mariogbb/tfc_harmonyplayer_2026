import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:player/data/data.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/model/album.dart';
import 'package:player/model/play_context.dart';
import 'package:player/model/sort.dart';
import 'package:player/ui/core/control_padding.dart';
import 'package:player/ui/core/desktop_content_scope.dart';
import 'package:player/ui/core/detail_header.dart';
import 'package:player/ui/core/neo_action_button.dart';
import 'package:player/ui/library/artists/artist_album_carusel.dart';
import 'package:player/ui/library/songs/song_list.dart';
import 'package:player/ui/playback/control_tab.dart';
import 'package:player/utils/extensions.dart';

class AlbumScreen extends StatelessWidget {
  const AlbumScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final album = ModalRoute.of(context)!.settings.arguments as AlbumData;
    final songs = album.songList;
    final related = album.artistData.albumList
        .where((item) => item.id != album.id)
        .toList();
    final labels = AppLocalizations.of(context)!;
    final fallback = Image.memory(album.artwork, fit: BoxFit.cover);
    return SafeArea(
      child: Scaffold(
        appBar: DesktopContentScope.isActive(context)
            ? null
            : AppBar(
                title: Text(
                  album.name,
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
              child: ListView(
                children: [
                  DetailHeader(
                    title: album.name,
                    subtitle:
                        '${album.artist} · ${songs.length} ${labels.plural_songs} · ${album.duration.toStringRepresentation()}',
                    onSubtitleTap: () => Navigator.pushNamed(
                      context,
                      'artist',
                      arguments: album.artistData,
                    ),
                    artwork: Hero(
                      tag: 'albumHero${album.id}',
                      child: album.imageURL == null
                          ? fallback
                          : CachedNetworkImage(
                              imageUrl: album.imageURL!,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => fallback,
                              errorWidget: (_, _, _) => fallback,
                            ),
                    ),
                    action: NeoActionButton(
                      onPressed: songs.isEmpty
                          ? null
                          : () {
                              PlayerData.instance.handler.playSongList(
                                PlayingContext(
                                  album.name,
                                  ContextType.album,
                                  songs,
                                ),
                                Random().nextInt(songs.length),
                              );
                              PlayerData.instance.handler.switchShuffleMode(
                                true,
                              );
                            },
                      icon: Icons.shuffle,
                      label: labels.shuffle_play,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      labels.plural_songs,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    trailing: Text('${songs.length}'),
                  ),
                  SongList(
                    playingContext: PlayingContext(
                      album.name,
                      ContextType.album,
                      songs,
                    ),
                    showArtistLabel: false,
                    showAlbum: true,
                    sort: SongSort(ascendent: true, type: SortType.trackNumber),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                  ),
                  if (related.isNotEmpty) ...[
                    ListTile(
                      title: Text(
                        '${labels.more_from} ${album.artist}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    SizedBox(
                      height: 155,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: related.length,
                        itemBuilder: (context, index) =>
                            AlbumCarouselContainer(data: related[index]),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
