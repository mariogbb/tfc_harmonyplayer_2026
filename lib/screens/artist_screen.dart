import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:player/data/data.dart';
import 'package:player/layout/adaptive_layout.dart';
import 'package:player/control/control_tab.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';
import 'package:player/model/play_context.dart';
import 'package:player/model/song.dart';
import 'package:player/screens/artist_album_carusel.dart';
import 'package:player/widgets/control_padding.dart';
import 'package:player/widgets/song_list.dart';
import 'package:player/model/sort.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/utils/extensions.dart';

class ArtistScreen extends StatefulWidget {
  const ArtistScreen({Key? key}) : super(key: key);

  @override
  ArtistScreenState createState() => ArtistScreenState();
}

class ArtistScreenState extends State<ArtistScreen>
    with AdaptiveElement<ArtistScreen> {
  int selectedSort = 0;
  bool ascendant = true;

  List<SortType> sorts = [
    SortType.alphabetical,
    SortType.trackNumber,
    SortType.album
  ];

  Widget _artistDetails(BuildContext context, ArtistData artistData) {
    return ListTile(
      title: Text(
        artistData.name,
        style: Theme.of(context)
            .textTheme
            .headlineMedium!
            .copyWith(fontFamily: "Inter", fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
          "${artistData.songList.length} ${AppLocalizations.of(context)!.plural_songs} . ${artistData.albumList.length} albums . ${artistData.duration.toStringRepresentation()}"),
    );
  }

  Widget _artistImage(ArtistData artistData, Axis orientation) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Hero(
        tag: "artistHero${artistData.id}",
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: (artistData.imageURL == null)
              ? Image.asset(
                  "assets/no_artwork_icon.png",
                  fit: (orientation == Axis.vertical)
                      ? BoxFit.fitWidth
                      : BoxFit.fitHeight,
                )
              : CachedNetworkImage(
                  imageUrl: artistData.imageURL!,
                  width: MediaQuery.of(context).size.width * 0.1,
                  cacheKey: artistData.id.toString(),
                  fit: (orientation == Axis.vertical)
                      ? BoxFit.fitWidth
                      : BoxFit.fitHeight,
                ),
        ),
      ),
    );
  }

  Widget randomButton(ArtistData artistData) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.shuffle),
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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
            PlayingContext(
                artistData.name, ContextType.artist, artistData.songList),
            rnd.nextInt(artistData.songList.length));
        PlayerData.instance.handler.switchShuffleMode(true);
      },
      label: Text(AppLocalizations.of(context)!.shuffle_play),
    );
  }

  @override
  Widget buildLarge(BuildContext context) {
    ArtistData artistData =
        ModalRoute.of(context)!.settings.arguments as ArtistData;

    List<AlbumData> albums = artistData.albumList;
    List<SongData> songs = artistData.songList;

    // Will be neccesary
    // final ScrollController controller =
    //    ScrollController(keepScrollOffset: false, initialScrollOffset: 0);

    return SafeArea(
      top: true,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        bottomSheet: PlayerControlTab(),
        body: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Stack(
                      fit: StackFit.passthrough,
                      children: [
                        _artistImage(artistData, Axis.horizontal),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: randomButton(artistData),
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
                      padding: const EdgeInsets.only(top: 20),
                      child: _artistDetails(
                        context,
                        artistData,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        AppLocalizations.of(context)!.albums_plural,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    SizedBox(
                      height: 155,
                      child: ListView.builder(
                        itemCount: albums.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return AlbumCarouselContainer(data: albums[index]);
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(
                        AppLocalizations.of(context)!.plural_songs,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      trailing: DropdownButton<int>(
                        onChanged: (value) {
                          setState(() {
                            selectedSort = value ?? 0;
                          });
                        },
                        value: selectedSort,
                        borderRadius: BorderRadius.circular(15),
                        items: [
                          const DropdownMenuItem<int>(
                            value: 0,
                            child: Text("A - Z"),
                          ),
                          DropdownMenuItem<int>(
                            value: 1,
                            child: Text(AppLocalizations.of(context)!
                                .track_number_sort),
                          ),
                          DropdownMenuItem<int>(
                            value: 2,
                            child: Text(AppLocalizations.of(context)!.album),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SongList(
                          playingContext: PlayingContext(
                              artistData.name, ContextType.artist, songs),
                          sort: SongSort(
                              ascendent: ascendant, type: sorts[selectedSort]),
                          showArtistLabel: false,
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                        ),
                      ],
                    ),
                    const ListTile()
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
    ArtistData artistData =
        ModalRoute.of(context)!.settings.arguments as ArtistData;

    List<AlbumData> albums = artistData.albumList;
    List<SongData> songs = artistData.songList;

    final ScrollController controller =
        ScrollController(keepScrollOffset: false, initialScrollOffset: 0);

    return SafeArea(
      top: true,
      child: Scaffold(
        appBar: AppBar(
          actions: const [],
          title: Text(artistData.model.artist),
        ),
        extendBodyBehindAppBar: true,
        bottomSheet: PlayerControlTab(),
        body: ControlPadding(
          child: SafeArea(
            child: ListView(
              controller: controller,
              children: [
                _artistImage(artistData, Axis.vertical),
                ListTile(
                  title: Text(
                    artistData.name,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontFamily: "Inter", fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    "${songs.length} ${AppLocalizations.of(context)!.plural_songs} . ${albums.length} albums . ${artistData.duration.toStringRepresentation()}",
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: randomButton(artistData),
                ),
                ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.albums_plural,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                SizedBox(
                  height: 155,
                  child: ListView.builder(
                    itemCount: albums.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return AlbumCarouselContainer(data: albums[index]);
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.plural_songs,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  trailing: DropdownButton<int>(
                    onChanged: (value) {
                      setState(() {
                        selectedSort = value ?? 0;
                      });
                    },
                    value: selectedSort,
                    borderRadius: BorderRadius.circular(15),
                    items: [
                      const DropdownMenuItem<int>(
                        value: 0,
                        child: Text("A - Z"),
                      ),
                      DropdownMenuItem<int>(
                        value: 1,
                        child: Text(
                            AppLocalizations.of(context)!.track_number_sort),
                      ),
                      DropdownMenuItem<int>(
                        value: 2,
                        child: Text(AppLocalizations.of(context)!.album),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SongList(
                      playingContext: PlayingContext(
                          artistData.name, ContextType.artist, songs),
                      sort: SongSort(
                        ascendent: ascendant,
                        type: sorts[selectedSort],
                      ),
                      showArtistLabel: false,
                      physics: const ClampingScrollPhysics(),
                      shrinkWrap: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
