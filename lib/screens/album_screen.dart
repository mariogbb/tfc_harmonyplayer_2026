import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:player/layout/adaptive_layout.dart';
import 'package:player/control/control_tab.dart';
import 'package:player/model/album.dart';
import 'package:player/data/data.dart';
import 'package:player/model/artist.dart';
import 'package:player/model/play_context.dart';
import 'package:player/model/song.dart';
import 'package:player/screens/artist_album_carusel.dart';
import 'package:player/widgets/control_padding.dart';
import 'package:player/widgets/song_list.dart';
import 'package:player/model/sort.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/utils/extensions.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({Key? key}) : super(key: key);

  @override
  AlbumScreenState createState() => AlbumScreenState();
}

class AlbumScreenState extends State<AlbumScreen>
    with AdaptiveElement<AlbumScreen> {
  bool _isTitleVisible = true;

  Widget _albumImage(BuildContext context, AlbumData data, Axis orientation) {
    return Hero(
      tag: "albumHero${data.id}",
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: AspectRatio(
          aspectRatio: 1,
          child: (data.imageURL == null)
              ? Image.memory(
                  data.artwork,
                  fit: (orientation == Axis.vertical)
                      ? BoxFit.fitWidth
                      : BoxFit.fitHeight,
                )
              : CachedNetworkImage(
                  imageUrl: data.imageURL!,
                  fit: (orientation == Axis.vertical)
                      ? BoxFit.fitWidth
                      : BoxFit.fitHeight,
                  placeholder: (context, url) {
                    return Image.memory(
                      data.artwork,
                      fit: (orientation == Axis.vertical)
                          ? BoxFit.fitWidth
                          : BoxFit.fitHeight,
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _artistImage(
      BuildContext context, ArtistData artist, Axis orientation) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, "artist", arguments: artist);
      },
      child: CircleAvatar(
        backgroundImage: (artist.imageURL == null)
            ? Image.asset("assets/no_artwork_icon.png").image
            : CachedNetworkImageProvider(artist.imageURL!),
      ),
    );
  }

  Widget _randomPlayButton(BuildContext context, AlbumData album) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.shuffle),
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
      onPressed: () {
        Random rnd = Random();

        PlayerData.instance.handler.playSongList(
            PlayingContext(album.name, ContextType.album, album.songList),
            rnd.nextInt(album.songList.length));
        PlayerData.instance.handler.switchShuffleMode(true);
      },
      label: Text(AppLocalizations.of(context)!.shuffle_play),
    );
  }

  ListTile _albumDetails(
      BuildContext context, AlbumData data, Axis orientation) {
    return ListTile(
      leading: _artistImage(context, data.artistData, orientation),
      title: VisibilityDetector(
        onVisibilityChanged: (info) {
          if (mounted) {
            if (info.visibleFraction == 0.0) {
              setState(() {
                _isTitleVisible = false;
              });
            } else {
              if (!_isTitleVisible) {
                setState(() {
                  _isTitleVisible = true;
                });
              }
            }
          }
        },
        key: const Key("artist_visibility_detector"),
        child: Text(
          data.name,
          maxLines: 2,
          overflow: TextOverflow.visible,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontFamily: "Inter",
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
        ),
      ),
      subtitle: Text(
        "${data.artist} - ${data.duration.toStringRepresentation()}",
      ),
    );
  }

  Widget _songsTitleTab(AlbumData data) {
    String songsText = AppLocalizations.of(context)!.plural_songs;

    songsText = songsText[0].toUpperCase() + songsText.substring(1);

    return ListTile(
      title: Row(
        verticalDirection: VerticalDirection.down,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            songsText,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            " (${data.songList.length})",
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildLarge(BuildContext context) {
    final AlbumData data =
        ModalRoute.of(context)!.settings.arguments as AlbumData;

    final List<SongData> songs = data.songList;
    final List<AlbumData> moreAlbums = data.artistData.albumList;

    moreAlbums.remove(data);

    songs.sort(
      (a, b) {
        if (a.model.track == null || b.model.track == null) {
          return 1;
        }

        return a.model.track!.compareTo(b.model.track!);
      },
    );

    return SafeArea(
      top: true,
      child: Scaffold(
        extendBody: false,
        extendBodyBehindAppBar: true,
        bottomSheet: PlayerControlTab(),
        body: SafeArea(
          bottom: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  children: [
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: _albumImage(context, data, Axis.horizontal),
                        ),
                        Positioned(
                          top: 20,
                          left: 20,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_sharp,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      child: _randomPlayButton(context, data),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 6,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: _albumDetails(context, data, Axis.vertical),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: _songsTitleTab(data),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SongList(
                          playingContext: PlayingContext(
                              data.name, ContextType.album, songs),
                          showArtistLabel: false,
                          showAlbum: true,
                          sort: SongSort(
                              ascendent: true, type: SortType.trackNumber),
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                        ),
                      ],
                    ),
                    if (moreAlbums.isNotEmpty) ...[
                      ListTile(
                        title: Text(
                          "${AppLocalizations.of(context)!.more_from} ${data.artist}",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      SizedBox(
                        height: 155,
                        child: ListView.builder(
                          itemCount: moreAlbums.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return AlbumCarouselContainer(
                                data: moreAlbums[index]);
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget buildNormal(BuildContext context) {
    final AlbumData data =
        ModalRoute.of(context)!.settings.arguments as AlbumData;

    final List<SongData> songs = data.songList;
    final List<AlbumData> moreAlbums = data.artistData.albumList;

    moreAlbums.remove(data);

    songs.sort(
      (a, b) {
        if (a.model.track == null || b.model.track == null) {
          return 1;
        }

        return a.model.track!.compareTo(b.model.track!);
      },
    );

    return SafeArea(
      top: true,
      child: Scaffold(
        appBar: AppBar(
          title: AnimatedOpacity(
            opacity: (_isTitleVisible) ? 0.0 : 1.0,
            curve: Curves.bounceIn,
            duration: const Duration(milliseconds: 400),
            child: Text(data.name),
          ),
        ),
        extendBody: false,
        extendBodyBehindAppBar: true,
        bottomSheet: PlayerControlTab(),
        body: ControlPadding(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: _albumImage(context, data, Axis.vertical),
              ),
              _albumDetails(context, data, Axis.vertical),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: _randomPlayButton(context, data),
              ),
              _songsTitleTab(data),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SongList(
                    playingContext:
                        PlayingContext(data.name, ContextType.album, songs),
                    showArtistLabel: false,
                    showAlbum: true,
                    sort: SongSort(ascendent: true, type: SortType.trackNumber),
                    physics: const ClampingScrollPhysics(),
                    shrinkWrap: true,
                  ),
                ],
              ),
              if (moreAlbums.isNotEmpty) ...[
                ListTile(
                  title: Text(
                    "${AppLocalizations.of(context)!.more_from} ${data.artist}",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                SizedBox(
                  height: 155,
                  child: ListView.builder(
                    itemCount: moreAlbums.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return AlbumCarouselContainer(data: moreAlbums[index]);
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
