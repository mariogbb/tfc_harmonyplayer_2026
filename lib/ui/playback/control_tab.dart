import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:player/ui/core/adaptive_layout.dart';
import 'package:player/data/data.dart';
import 'package:player/model/play_context.dart';
import 'package:player/model/song.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/control/media_control.dart';
import 'package:player/ui/core/generic_artwork.dart';
import 'package:player/ui/playlists/playlist_controller.dart';
import 'package:player/ui/playback/queue_carousel.dart';
import 'package:player/theme_data/neo_style.dart';
import 'package:player/ui/core/neo_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:player/utils/extensions.dart';
import 'package:player/data/services/artwork/fallback_artwork.dart';

class PlayerControlTab extends StatefulWidget {
  PlayerControlTab({Key? key, this.onEvent, PlayerHandler? handler})
    : handler = handler ?? PlayerData.instance.handler,
      super(key: key);

  final PlayerData playerData = PlayerData();
  final PlayerHandler handler;
  final ValueChanged<bool>? onEvent;

  @override
  State<PlayerControlTab> createState() => PlayerControlTabState();
}

class PlayerControlTabState extends State<PlayerControlTab>
    with AdaptiveElement<PlayerControlTab>, SingleTickerProviderStateMixin {
  List<IconData> icons = [Icons.play_arrow, Icons.pause];

  bool _opened = false;

  final DraggableScrollableController normalScrollController =
      DraggableScrollableController();

  final DraggableScrollableController largeScrollController =
      DraggableScrollableController();

  @override
  void dispose() {
    normalScrollController.dispose();
    largeScrollController.dispose();
    super.dispose();
  }

  void _setPlayerExpanded(bool expanded, {required bool large}) {
    final controller = large ? largeScrollController : normalScrollController;
    if (!controller.isAttached) return;
    controller.animateTo(
      expanded ? 1 : (large ? 0.2 : 0.1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  bool _isLiked(SongData? data) {
    return context.read<PlaylistController>().playlists.any(
      (playlist) =>
          playlist.id == 1 && playlist.songs.any((song) => song.id == data?.id),
    );
  }

  Future<void> _toggleLike(PlaylistController playlists, SongData? song) async {
    if (song == null) return;
    final liked = playlists.playlists.where((playlist) => playlist.id == 1);
    if (liked.isEmpty) return;
    if (liked.first.songs.any((item) => item.id == song.id)) {
      await playlists.removeSong(liked.first, song);
    } else {
      await playlists.addSong(liked.first, song);
    }
  }

  String _getTopContextString(PlayingContext playingContext) {
    switch (playingContext.getContext) {
      case ContextType.album:
        return AppLocalizations.of(context)!.playing_from_album;
      case ContextType.song:
        return AppLocalizations.of(context)!.playing_from_song;
      case ContextType.playlist:
        return AppLocalizations.of(context)!.playing_from_playlist;
      case ContextType.artist:
        return AppLocalizations.of(context)!.playing_from_artist;
      case ContextType.allSongs:
        return AppLocalizations.of(context)!.playing_from_all_songs;
      case ContextType.topPlayedAlbums:
        return AppLocalizations.of(context)!.playing_from_top_albums;
      case ContextType.topPlayedSongs:
        return AppLocalizations.of(context)!.playing_from_top_songs;
    }
  }

  Widget nextSongButton() {
    return NeoIconButton(
      onPressed: () {
        widget.handler.next();
      },
      tooltip: AppLocalizations.of(context)!.next_track,
      icon: Icons.skip_next,
    );
  }

  Widget previousSongButton() {
    return NeoIconButton(
      onPressed: () {
        widget.handler.previous();
      },
      tooltip: AppLocalizations.of(context)!.previous_track,
      icon: Icons.skip_previous,
    );
  }

  Consumer shuffleSongButton() {
    return Consumer<PlayerHandler>(
      builder: (context, value, child) {
        return NeoIconButton(
          selected: value.shuffle,
          tooltip: AppLocalizations.of(context)!.shuffle,
          onPressed: () {
            widget.handler.switchShuffleMode(!widget.handler.shuffle);
          },
          icon: Icons.shuffle,
        );
      },
    );
  }

  Widget _albumImageCarousel(
    BuildContext context,
    Axis orientation, {
    double? height,
  }) {
    return Consumer<PlayerHandler>(
      builder: (context, value, child) {
        return QueueCarousel(
          itemCount: value.getCompleteQueue.length,
          index: value.getPlayingIndex,
          itemBuilder: (context, index) {
            return _albumImage(
              context,
              orientation,
              value.getCompleteQueue[index],
            );
          },
          height:
              height ??
              ((orientation == Axis.vertical)
                  ? MediaQuery.of(context).size.height * 0.4
                  : MediaQuery.of(context).size.height * 0.8),
          onManualPage: (index) {
            if (value.getPlayingIndex > index) {
              widget.handler.previous();
            } else {
              widget.handler.next();
            }
          },
        );
      },
    );
  }

  Widget _albumImage(BuildContext context, Axis orientation, SongData? song) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Consumer<PlayerHandler>(
        builder: (context, value, child) {
          if (song == null) {
            return Image.memory(fallbackArtwork, fit: BoxFit.cover);
          }

          if (song.albumModel.imageURL == null) {
            return Image.memory(song.albumModel.artwork, fit: BoxFit.cover);
          }

          return CachedNetworkImage(
            imageUrl: song.albumModel.imageURL ?? "",
            fadeInDuration: Duration.zero,
            cacheKey: song.albumModel.id.toString(),
            placeholder: (context, url) {
              return Image.memory(song.artwork, fit: BoxFit.cover);
            },
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }

  Widget pauseSongButton(bool paused) {
    return NeoIconButton(
      primary: true,
      tooltip: paused
          ? AppLocalizations.of(context)!.play
          : AppLocalizations.of(context)!.pause,
      onPressed: () {
        if (widget.handler.isPaused) {
          widget.handler.play();
        } else {
          widget.handler.pause();
        }
      },
      icon: paused ? icons[0] : icons[1],
    );
  }

  Widget songSlider(Duration duration, Duration position) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 4,
        thumbColor: Theme.of(context).primaryColor,
      ),
      child: Slider(
        activeColor: Theme.of(context).primaryColor,
        value: position.inSeconds
            .clamp(0, duration.inSeconds < 0 ? 0 : duration.inSeconds)
            .toDouble(),
        max: duration.inSeconds.clamp(0, double.maxFinite).toDouble(),
        divisions: (duration.inSeconds > 0) ? duration.inSeconds : 1,
        min: 0.0,
        onChanged: (value) {
          widget.handler.seek(Duration(seconds: value.toInt()));
        },
      ),
    );
  }

  Widget _artistNameText(SongData? song) {
    return GestureDetector(
      onTap: () {
        if (song != null) {
          Navigator.of(context)
              .pushNamed("artist", arguments: song.artistModel);
        }
      },
      child: ListTile(
        title: Text(
          song?.artist ?? "",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }

  Widget _songNameText(SongData? song) {
    return GestureDetector(
      onTap: () {
        if (song != null) {
          Navigator.of(context).pushNamed("album", arguments: song.albumModel);
        }
      },
      child: ListTile(
        title: Text(
          song?.title ?? "",
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _openedPlayer({required bool large}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 700;
        final artworkSize =
            (wide ? constraints.maxWidth * 0.38 : constraints.maxWidth - 48)
                .clamp(0.0, wide ? 380.0 : 320.0)
                .clamp(0.0, MediaQuery.sizeOf(context).height * 0.42);
        final artwork = Center(
          child: SizedBox(
            width: artworkSize,
            child: _albumImageCarousel(
              context,
              Axis.vertical,
              height: artworkSize,
            ),
          ),
        );
        final details = Consumer2<PlayerHandler, PlaylistController>(
          builder: (context, player, playlists, _) {
            final song = player.playingSong;
            return Container(
              decoration: NeoStyle.raised(context, radius: 24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _songNameText(song),
                  _artistNameText(song),
                  const SizedBox(height: 12),
                  songSlider(player.getDuration, player.getPosition),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          player.getPosition.toStringRepresentation(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          player.getDuration.toStringRepresentation(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      NeoIconButton(
                        onPressed: () => _toggleLike(playlists, song),
                        selected: _isLiked(song),
                        tooltip: AppLocalizations.of(context)!.toggle_like,
                        icon: _isLiked(song)
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      previousSongButton(),
                      pauseSongButton(player.isPaused),
                      nextSongButton(),
                      shuffleSongButton(),
                    ],
                  ),
                ],
              ),
            );
          },
        );
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Consumer<PlayerHandler>(
                    builder: (context, player, _) {
                      final playingContext = player.getPlayingContext;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          onPressed: () =>
                              _setPlayerExpanded(false, large: large),
                        ),
                        title: Text(
                          playingContext == null
                              ? AppLocalizations.of(context)!.now_playing
                              : _getTopContextString(playingContext),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: playingContext == null
                            ? null
                            : Text(
                                playingContext.getName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: artwork),
                        const SizedBox(width: 32),
                        Expanded(child: details),
                      ],
                    )
                  else ...[
                    artwork,
                    const SizedBox(height: 24),
                    details,
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _closedNormalWidget() {
    return GestureDetector(
      onTap: () => _setPlayerExpanded(true, large: false),
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! > 0) {
            widget.handler.next();
          } else {
            widget.handler.previous();
          }
        }
      },
      child: Consumer<PlayerHandler>(
        builder: (context, value, child) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
            child: Center(
              child: ListTile(
                leading: GenericArtwork(
                  type: ArtworkType.song,
                  shape: ArtworkShape.square,
                  elementId: value.playingSong!.id,
                  artwork: value.playingSong!.artwork,
                ),
                title: Text(
                  value.playingSong?.title ?? "",
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                subtitle: Text(
                  value.playingSong?.artist ?? "",
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                trailing: pauseSongButton(value.isPaused),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _closedLargeWidget() {
    return SafeArea(
      bottom: true,
      child: GestureDetector(
        onTap: () => _setPlayerExpanded(true, large: true),
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! > 0) {
              widget.handler.next();
            } else {
              widget.handler.previous();
            }
          }
        },
        child: Container(
          decoration: const BoxDecoration(),
          child: Consumer<PlayerHandler>(
            builder: (context, value, child) {
              return PreferredSize(
                preferredSize: Size.fromHeight(
                  MediaQuery.of(context).size.height * 0.1,
                ),
                child: ListTile(
                  leading: GenericArtwork(
                    type: ArtworkType.song,
                    shape: ArtworkShape.square,
                    elementId: value.playingSong!.id,
                    artwork: value.playingSong!.artwork,
                  ),
                  title: Text(
                    value.playingSong?.title ?? "",
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Text(
                    value.playingSong?.artist ?? "",
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      previousSongButton(),
                      pauseSongButton(value.isPaused),
                      nextSongButton(),
                      IconButton(
                        tooltip: AppLocalizations.of(context)!.now_playing,
                        onPressed: () => _setPlayerExpanded(true, large: true),
                        icon: const Icon(Icons.keyboard_arrow_up_rounded),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget buildLarge(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      child: NotificationListener<DraggableScrollableNotification>(
        onNotification: (value) {
          double switchValue = 0.4;
          bool prevState = _opened;

          if (value.extent == value.minExtent) {
            setState(() {
              _opened = false;
            });
          }

          if (!_opened && value.extent >= switchValue) {
            setState(() {
              _opened = true;
            });
          } else if (_opened && value.extent < switchValue) {
            setState(() {
              _opened = false;
            });
          }

          if (prevState != _opened) {
            widget.onEvent?.call(_opened);
          }

          return false;
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: (context.watch<PlayerHandler>().lastError != null)
              ? Material(
                  child: ListTile(
                    title: Text(AppLocalizations.of(context)!.playback_error),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: widget.handler.retry,
                    ),
                  ),
                )
              : (context.watch<PlayerHandler>().playingSong != null)
              ? Container(
                  decoration: NeoStyle.raised(context, radius: 24),
                  key: const Key("scrollable_detector_large"),
                  child: DraggableScrollableSheet(
                    key: const Key("scrollable-control_large"),
                    snap: true,
                    snapSizes: const [0.2, 1],
                    controller: largeScrollController,
                    expand: false,
                    maxChildSize: 1.0,
                    initialChildSize: 0.2,
                    minChildSize: 0.2,
                    builder: (context, scrollController) => ListView(
                      controller: scrollController,
                      children: [
                        AnimatedSwitcher(
                          switchInCurve: Curves.ease,
                          switchOutCurve: Curves.ease,
                          duration: const Duration(milliseconds: 180),
                          reverseDuration: const Duration(milliseconds: 100),
                          child: (_opened)
                              ? _openedPlayer(large: true)
                              : _closedLargeWidget(),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(key: Key("invisible_box_large")),
        ),
      ),
    );
  }

  @override
  Widget buildNormal(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (value) {
        double switchValue = 0.15;
        bool prevValue = _opened;

        if (value.extent == value.minExtent) {
          setState(() {
            _opened = false;
          });
        }

        if (!_opened && value.extent >= switchValue) {
          setState(() {
            _opened = true;
          });
        } else if (_opened && value.extent < switchValue) {
          setState(() {
            _opened = false;
          });
        }

        if (prevValue != _opened) {
          widget.onEvent?.call(_opened);
        }
        return true;
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: (context.watch<PlayerHandler>().lastError != null)
            ? Material(
                child: ListTile(
                  title: Text(AppLocalizations.of(context)!.playback_error),
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: widget.handler.retry,
                  ),
                ),
              )
            : (context.watch<PlayerHandler>().playingSong != null)
            ? Container(
                decoration: NeoStyle.raised(context, radius: 24),
                key: const Key("scrollable_detector"),
                child: DraggableScrollableSheet(
                  key: const Key("scrollable-control"),
                  snap: true,
                  snapSizes: const [0.1, 1.0],
                  controller: normalScrollController,
                  expand: false,
                  maxChildSize: 1.0,
                  initialChildSize: 0.1,
                  minChildSize: 0.1,
                  builder: (context, scrollController) => ListView(
                    controller: scrollController,
                    children: [
                      AnimatedSwitcher(
                        switchInCurve: Curves.ease,
                        switchOutCurve: Curves.ease,
                        duration: const Duration(milliseconds: 180),
                        reverseDuration: const Duration(milliseconds: 100),
                        child: (_opened)
                            ? _openedPlayer(large: false)
                            : _closedNormalWidget(),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox.shrink(key: Key("invisible_box")),
      ),
    );
  }
}
