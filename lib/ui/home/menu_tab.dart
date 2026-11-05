import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:player/data/settings.dart';
import 'package:player/ui/home/user_name.dart';
import 'package:player/ui/core/adaptive_layout.dart';
import 'package:player/ui/library/library_controller.dart';
import 'package:player/model/album.dart';
import 'package:player/model/song.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/theme_data/theme_provider.dart';
import 'package:player/model/sort.dart';
import 'package:player/model/top_recopilations.dart';
import 'package:player/ui/core/artwork_card.dart';
import 'package:player/ui/core/generic_artwork.dart';
import 'package:provider/provider.dart';

class PlayerMenuTab extends StatelessAdaptiveLayout {
  const PlayerMenuTab({Key? key}) : super(key: key);

  Widget wellcomeWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: OrientationBuilder(
          builder: (context, orientation) {
            return Stack(
              children: [
                Positioned(
                  child: Image.asset(
                    "assets/wellcome_mountain.jpg",
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  bottom: 7.5,
                  left: (orientation == Orientation.landscape) ? 40 : 0,
                  right: 0,
                  child: ListTile(
                    leading: Consumer<ThemeProvider>(
                      child: const Icon(Icons.person_rounded),
                      builder: (context, value, child) {
                        return CircleAvatar(
                          radius: 25,
                          backgroundColor: value.selectedPrimaryColor,
                          child: child,
                        );
                      },
                    ),
                    title: Text(
                      "${AppLocalizations.of(context)!.wellcome_user}, ",
                      style: Theme.of(context).textTheme.titleLarge!
                          .copyWith(color: Colors.white),
                    ),
                    subtitle: GestureDetector(
                      onTap: () {
                        UserNameDialog.changeUserNameDialog(context);
                      },
                      child: Consumer<PlayerSettings>(
                        builder: (context, value, child) {
                          return Text(
                            value.getUserName ??
                                AppLocalizations.of(context)!.default_user_name,
                            style: Theme.of(context).textTheme.headlineSmall!
                                .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  GestureDetector topSongsLabel(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          "top_played_songs",
          arguments: RankingData(type: Ranking.allTime),
        );
      },
      child: ListTile(
        title: Text(
          AppLocalizations.of(context)!.top_songs,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  GestureDetector topAlbumsLabel(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          "top_played_albums",
          arguments: RankingData(type: Ranking.allTime),
        );
      },
      child: ListTile(
        title: Text(
          AppLocalizations.of(context)!.top_albums,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  Widget topSongsList(BuildContext context) {
    return Consumer<LibraryController>(
      builder: (context, value, child) {
        if (value.songList.isEmpty) {
          return const Text("");
        }

        List<SongData> topSongs = List.from(value.songList);

        SongSort sort = SongSort(ascendent: false, type: SortType.playingTime);

        topSongs.sort(sort.sort);

        if (topSongs.length > 10) {
          topSongs.removeRange(10, topSongs.length);
        }

        return SizedBox(
          child: CarouselSlider.builder(
            options: CarouselOptions(
              scrollPhysics: const BouncingScrollPhysics(),
              enableInfiniteScroll: false,
              initialPage: 1,
              viewportFraction: 0.33,
              enlargeStrategy: CenterPageEnlargeStrategy.height,
            ),
            itemCount: topSongs.length,
            itemBuilder: (context, index, realIndex) {
              return ArtworkCard(
                title: topSongs[index].title,
                subTitle: topSongs[index].artist,
                artwork: GenericArtwork(
                  fit: BoxFit.fitHeight,
                  artwork: topSongs[index].artwork,
                  elementId: topSongs[index].id,
                  shape: ArtworkShape.circle,
                  type: ArtworkType.album,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget topAlbumsList(BuildContext context) {
    return Consumer<LibraryController>(
      builder: (context, value, child) {
        if (value.albumList.isEmpty) {
          return const Text("");
        }

        List<AlbumData> topSongs = List.from(value.albumList);
        AlbumSort sort = AlbumSort(
          ascendent: false,
          type: SortType.playingTime,
        );

        topSongs.sort(sort.sort);
        if (topSongs.length > 10) {
          topSongs.removeRange(10, topSongs.length);
        }

        return SizedBox(
          child: CarouselSlider.builder(
            options: CarouselOptions(
              scrollPhysics: const BouncingScrollPhysics(),
              enableInfiniteScroll: false,
              initialPage: 1,
              viewportFraction: 0.33,
              enlargeStrategy: CenterPageEnlargeStrategy.height,
            ),
            itemCount: topSongs.length,
            itemBuilder: (context, index, realIndex) {
              return ArtworkCard(
                title: topSongs[index].name,
                subTitle: topSongs[index].artist,
                artwork: GenericArtwork(
                  fit: BoxFit.fitHeight,
                  artwork: topSongs[index].artwork,
                  elementId: topSongs[index].id,
                  shape: ArtworkShape.circle,
                  type: ArtworkType.album,
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget buildLarge(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      children: [
        wellcomeWidget(context),
        topAlbumsLabel(context),
        topAlbumsList(context),
        topSongsLabel(context),
        topSongsList(context),
      ],
    );
  }

  @override
  Widget buildNormal(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      children: [
        Flex(
          direction: Axis.vertical,
          children: [
            ListView(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              children: [
                wellcomeWidget(context),
                topAlbumsLabel(context),
                topAlbumsList(context),
                topSongsLabel(context),
                topSongsList(context),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
