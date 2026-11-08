import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:player/data/services/artwork/fallback_artwork.dart';
import 'package:flutter/material.dart';
import 'package:player/data/data.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/model/artist.dart';
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

class ArtistScreen extends StatefulWidget {
  const ArtistScreen({super.key});
  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  SortType sort = SortType.alphabetical;
  @override
  Widget build(BuildContext context) {
    final artist = ModalRoute.of(context)!.settings.arguments as ArtistData;
    final songs = artist.songList;
    final albums = artist.albumList;
    final labels = AppLocalizations.of(context)!;
    final placeholder = Image.memory(fallbackArtwork, fit: BoxFit.cover);
    return SafeArea(
      child: Scaffold(
        appBar: DesktopContentScope.isActive(context)
            ? null
            : AppBar(
                title: Text(
                  artist.name,
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
                    title: artist.name,
                    subtitle:
                        '${songs.length} ${labels.plural_songs} · ${albums.length} ${labels.albums_plural} · ${artist.duration.toStringRepresentation()}',
                    artwork: Hero(
                      tag: 'artistHero${artist.id}',
                      child: artist.imageURL == null
                          ? placeholder
                          : CachedNetworkImage(
                              imageUrl: artist.imageURL!,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => placeholder,
                              errorWidget: (_, _, _) => placeholder,
                            ),
                    ),
                    action: NeoActionButton(
                      onPressed: songs.isEmpty
                          ? null
                          : () {
                              PlayerData.instance.handler.playSongList(
                                PlayingContext(
                                  artist.name,
                                  ContextType.artist,
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
                  if (albums.isNotEmpty) ...[
                    ListTile(
                      title: Text(
                        labels.albums_plural,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      trailing: Text('${albums.length}'),
                    ),
                    SizedBox(
                      height: 155,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: albums.length,
                        itemBuilder: (context, index) =>
                            AlbumCarouselContainer(data: albums[index]),
                      ),
                    ),
                  ],
                  ListTile(
                    title: Text(
                      labels.plural_songs,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    trailing: DropdownButton<SortType>(
                      value: sort,
                      onChanged: (value) {
                        if (value != null) setState(() => sort = value);
                      },
                      items: [
                        const DropdownMenuItem(
                          value: SortType.alphabetical,
                          child: Text('A - Z'),
                        ),
                        DropdownMenuItem(
                          value: SortType.trackNumber,
                          child: Text(labels.track_number_sort),
                        ),
                        DropdownMenuItem(
                          value: SortType.album,
                          child: Text(labels.album),
                        ),
                      ],
                    ),
                  ),
                  SongList(
                    playingContext: PlayingContext(
                      artist.name,
                      ContextType.artist,
                      songs,
                    ),
                    sort: SongSort(ascendent: true, type: sort),
                    showArtistLabel: false,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                  ),
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
