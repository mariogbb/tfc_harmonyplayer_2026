import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:player/data/settings.dart';
import 'package:player/ui/home/user_name.dart';
import 'package:player/ui/core/adaptive_layout.dart';
import 'package:player/ui/library/library_controller.dart';
import 'package:player/model/album.dart';
import 'package:player/model/song.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/theme_data/neo_style.dart';
import 'package:player/model/sort.dart';
import 'package:player/model/top_recopilations.dart';
import 'package:player/ui/core/artwork_card.dart';
import 'package:player/ui/core/generic_artwork.dart';
import 'package:provider/provider.dart';
import 'package:player/data/data.dart';
import 'package:player/model/play_context.dart';

class PlayerMenuTab extends StatelessAdaptiveLayout {
  const PlayerMenuTab({Key? key}) : super(key: key);

  Widget wellcomeWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Container(
        decoration: NeoStyle.raised(context, radius: 26),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.wellcome_user,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Consumer<PlayerSettings>(
                    builder: (context, value, child) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () =>
                            UserNameDialog.changeUserNameDialog(context),
                        child: Text(
                          value.getUserName ??
                              AppLocalizations.of(context)!.default_user_name,
                          style: Theme.of(context).textTheme.headlineSmall!
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Consumer<LibraryController>(
                    builder: (context, library, _) => Wrap(
                      spacing: 14,
                      runSpacing: 8,
                      children: [
                        _libraryStat(
                          context,
                          Icons.music_note_rounded,
                          library.songList.length,
                          AppLocalizations.of(context)!.songs_tab,
                        ),
                        _libraryStat(
                          context,
                          Icons.album_outlined,
                          library.albumList.length,
                          AppLocalizations.of(context)!.albums_tab,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 52,
              height: 52,
              decoration: NeoStyle.raised(context, radius: 18),
              child: Icon(
                Icons.graphic_eq_rounded,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _libraryStat(
    BuildContext context,
    IconData icon,
    int count,
    String label,
  ) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.primaryColor),
        const SizedBox(width: 5),
        Text('$count $label', style: theme.textTheme.bodySmall),
      ],
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

        return _artworkRail(
          itemCount: topSongs.length,
          itemBuilder: (context, index) {
            return ArtworkCard(
              title: topSongs[index].title,
              subTitle: topSongs[index].artist,
              onTap: () => PlayerData.instance.handler.playSongList(
                PlayingContext(
                  AppLocalizations.of(context)!.top_played_songs,
                  ContextType.topPlayedSongs,
                  topSongs,
                ),
                index,
              ),
              artwork: GenericArtwork(
                fit: BoxFit.fitHeight,
                artwork: topSongs[index].artwork,
                imageUrl: topSongs[index].albumModel.imageURL,
                elementId: topSongs[index].id,
                shape: ArtworkShape.circle,
                type: ArtworkType.song,
              ),
            );
          },
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

        return _artworkRail(
          itemCount: topSongs.length,
          itemBuilder: (context, index) {
            return ArtworkCard(
              title: topSongs[index].name,
              subTitle: topSongs[index].artist,
              onTap: () => Navigator.pushNamed(
                context,
                'album',
                arguments: topSongs[index],
              ),
              artwork: GenericArtwork(
                fit: BoxFit.fitHeight,
                artwork: topSongs[index].artwork,
                imageUrl: topSongs[index].imageURL,
                elementId: topSongs[index].id,
                shape: ArtworkShape.circle,
                type: ArtworkType.album,
              ),
            );
          },
        );
      },
    );
  }

  Widget _artworkRail({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth * 0.42).clamp(140.0, 190.0);
        final textScale = MediaQuery.textScalerOf(context)
            .scale(1)
            .clamp(1.0, 2.0);
        return SizedBox(
          height: width + 70 * textScale,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
              },
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
              itemCount: itemCount,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (context, index) =>
                  SizedBox(width: width, child: itemBuilder(context, index)),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildLarge(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        padding: const EdgeInsets.only(top: 56, bottom: 24),
        children: [
          wellcomeWidget(context),
          if (constraints.maxWidth >= 900)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [topAlbumsLabel(context), topAlbumsList(context)],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [topSongsLabel(context), topSongsList(context)],
                  ),
                ),
              ],
            )
          else ...[
            topAlbumsLabel(context),
            topAlbumsList(context),
            topSongsLabel(context),
            topSongsList(context),
          ],
        ],
      ),
    );
  }

  @override
  Widget buildNormal(BuildContext context) {
    return buildLarge(context);
  }
}
