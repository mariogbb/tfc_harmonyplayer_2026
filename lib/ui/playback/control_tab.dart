import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:player/ui/core/adaptive_layout.dart';
import 'package:player/data/data.dart';
import 'package:player/model/play_context.dart';
import 'package:player/model/playlist.dart';
import 'package:player/model/song.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/control/media_control.dart';
import 'package:player/ui/core/generic_artwork.dart';
import 'package:player/ui/playlists/playlist_controller.dart';
import 'package:provider/provider.dart';
import 'package:player/utils/extensions.dart';

class PlayerControlTab extends StatefulWidget {
  PlayerControlTab({Key? key, this.onEvent}) : super(key: key);

  final PlayerData playerData = PlayerData();
  final PlayerHandler handler = PlayerData.instance.handler;
  final ValueChanged<bool>? onEvent;

  @override
  State<PlayerControlTab> createState() => PlayerControlTabState();
}

class PlayerControlTabState extends State<PlayerControlTab>
    with AdaptiveElement<PlayerControlTab>, SingleTickerProviderStateMixin {
  List<IconData> icons = [Icons.play_arrow, Icons.pause];

  bool _opened = false;

  final CarouselSliderController carouselController =
      CarouselSliderController();
  final DraggableScrollableController normalScrollController =
      DraggableScrollableController();

  final DraggableScrollableController largeScrollController =
      DraggableScrollableController();

  bool _isLiked(SongData? data) {
    bool liked = false;

    try {
      PlaylistData playlistData = context
          .read<PlaylistController>()
          .playlists
          .firstWhere((element) => element.id == 1);

      liked = playlistData.songs.contains(data);
    } catch (_) {}

    return liked;
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

  IconButton nextSongButton() {
    return IconButton(
      onPressed: () {
        widget.handler.next();
        carouselController.nextPage();
      },
      icon: const Icon(Icons.skip_next),
    );
  }

  IconButton previousSongButton() {
    return IconButton(
      onPressed: () {
        widget.handler.previous();
        carouselController.previousPage();
      },
      icon: const Icon(Icons.skip_previous),
    );
  }

  Consumer shuffleSongButton() {
    return Consumer<PlayerHandler>(
      builder: (context, value, child) {
        return IconButton(
          color: (value.shuffle) ? Theme.of(context).primaryColor : null,
          onPressed: () {
            widget.playerData.handler.switchShuffleMode(
              !widget.playerData.handler.shuffle,
            );
          },
          icon: const Icon(Icons.shuffle),
        );
      },
    );
  }

  Widget _albumImageCarousel(BuildContext context, Axis orientation) {
    return Consumer<PlayerHandler>(
      builder: (context, value, child) {
        return CarouselSlider.builder(
          itemCount: value.getCompleteQueue.length,
          itemBuilder: (context, index, realIndex) {
            return _albumImage(
              context,
              orientation,
              value.getCompleteQueue[index],
            );
          },
          carouselController: carouselController,
          options: CarouselOptions(
            viewportFraction: 1,
            initialPage: value.getPlayingIndex,
            enlargeCenterPage: true,
            height: (orientation == Axis.vertical)
                ? MediaQuery.of(context).size.height * 0.4
                : MediaQuery.of(context).size.height * 0.8,
            enlargeStrategy: CenterPageEnlargeStrategy.height,
            enlargeFactor: 0.5,
            onPageChanged: (index, reason) {
              if (reason == CarouselPageChangedReason.manual) {
                if (value.getPlayingIndex > index) {
                  if (index != 0) {
                    widget.handler.previous();
                  }
                } else {
                  if (index != (value.getCompleteQueue.length - 1)) {
                    widget.handler.next();
                  }
                }
              }
            },
            disableCenter: false,
            enableInfiniteScroll: false,
            scrollPhysics: const BouncingScrollPhysics(),
          ),
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
            return Image.asset("assets/no_artwork_icon.png", fit: BoxFit.fill);
          }

          if (song.albumModel.imageURL == null) {
            return Image.memory(song.albumModel.artwork, fit: BoxFit.fill);
          }

          return CachedNetworkImage(
            imageUrl: song.albumModel.imageURL ?? "",
            fadeInDuration: Duration.zero,
            cacheKey: song.albumModel.id.toString(),
            placeholder: (context, url) {
              return Image.memory(value.playingSong!.artwork, fit: BoxFit.fill);
            },
            fit: BoxFit.fill,
          );
        },
      ),
    );
  }

  Widget pauseSongButton(bool paused) {
    return IconButton(
      onPressed: () {
        if (widget.handler.isPaused) {
          widget.handler.play();
        } else {
          widget.handler.pause();
        }
      },
      icon: paused ? Icon(icons[0]) : Icon(icons[1]),
    );
  }

  Widget songSlider(Duration duration, Duration position) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 1,
        thumbColor: Theme.of(context).primaryColor,
      ),
      child: Slider(
        activeColor: Theme.of(context).primaryColor,
        value: position.inSeconds.toDouble(),
        max: duration.inSeconds.toDouble(),
        divisions: (duration.inSeconds > 0) ? duration.inSeconds : 1,
        min: 0.0,
        onChanged: (value) {
          widget.playerData.handler.seek(Duration(seconds: value.toInt()));
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

  Widget _openedLargeWidget() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      verticalDirection: VerticalDirection.down,
      children: [
        Expanded(
          flex: 1,
          child: ListView(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: _albumImageCarousel(context, Axis.horizontal),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: ListView(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            children: [
              Consumer<PlayerHandler>(
                builder: (context, value, child) {
                  PlayingContext? playingContext = value.getPlayingContext;
                  String topString = AppLocalizations.of(context)!.now_playing;
                  String subtitleString = AppLocalizations.of(context)!
                      .liked_songs;

                  if (playingContext != null) {
                    topString = _getTopContextString(playingContext);
                    subtitleString = playingContext.getName;
                  }

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                    leading: IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      onPressed: () {
                        largeScrollController.animateTo(
                          0.075,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.linear,
                        );
                      },
                    ),
                    title: Text(topString, textAlign: TextAlign.center),
                    subtitle: Text(subtitleString, textAlign: TextAlign.center),
                    trailing: IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {},
                    ),
                  );
                },
              ),
              Consumer<PlayerHandler>(
                builder: (context, value, child) {
                  return ListTile(
                    horizontalTitleGap: 0,
                    leading: Text(value.getPosition.toStringRepresentation()),
                    trailing: Text(value.getDuration.toStringRepresentation()),
                    title: songSlider(value.getDuration, value.getPosition),
                  );
                },
              ),
              Consumer<PlayerHandler>(
                builder: (context, value, child) {
                  return _songNameText(value.playingSong);
                },
              ),
              Consumer<PlayerHandler>(
                builder: (context, value, child) {
                  return _artistNameText(value.playingSong);
                },
              ),
              const Padding(padding: EdgeInsets.only(top: 40)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Consumer2<PlayerHandler, PlaylistController>(
                    builder: (context, value, playlists, child) {
                      return IconButton(
                        onPressed: () async {
                          PlaylistData playlistData = playlists.playlists
                              .firstWhere((element) => element.id == 1);

                          if (value.playingSong != null) {
                            if (_isLiked(value.playingSong)) {
                              await playlists.removeSong(
                                playlistData,
                                value.playingSong!,
                              );
                            } else {
                              await playlists.addSong(
                                playlistData,
                                value.playingSong!,
                              );
                            }
                          }
                        },
                        icon: (_isLiked(value.playingSong))
                            ? Icon(
                                Icons.favorite,
                                color: Theme.of(context).primaryColor,
                              )
                            : const Icon(Icons.favorite_border),
                      );
                    },
                  ),
                  previousSongButton(),
                  Consumer<PlayerHandler>(
                    builder: (context, value, child) {
                      return pauseSongButton(value.isPaused);
                    },
                  ),
                  nextSongButton(),
                  shuffleSongButton(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _openedNormalWidget() {
    return ListView(
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
      children: [
        Consumer<PlayerHandler>(
          builder: (context, value, child) {
            PlayingContext? playingContext = value.getPlayingContext;
            String topString = AppLocalizations.of(context)!.now_playing;
            String subtitleString = AppLocalizations.of(context)!.liked_songs;

            if (playingContext != null) {
              topString = _getTopContextString(playingContext);
              subtitleString = playingContext.getName;
            }
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 5),
              leading: IconButton(
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                onPressed: () {
                  normalScrollController.animateTo(
                    0.075,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.linear,
                  );
                },
              ),
              title: Text(topString, textAlign: TextAlign.center),
              subtitle: Text(subtitleString, textAlign: TextAlign.center),
              trailing: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {},
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 10, right: 20),
          child: Consumer<PlayerHandler>(
            builder: (context, value, child) {
              return _albumImageCarousel(context, Axis.vertical);
            },
          ),
        ),
        Consumer<PlayerHandler>(
          builder: (context, value, child) {
            return ListTile(
              horizontalTitleGap: 0,
              leading: Text(value.getPosition.toStringRepresentation()),
              trailing: Text(value.getDuration.toStringRepresentation()),
              title: songSlider(value.getDuration, value.getPosition),
            );
          },
        ),
        Consumer<PlayerHandler>(
          builder: (context, value, child) {
            return _songNameText(value.playingSong);
          },
        ),
        Consumer<PlayerHandler>(
          builder: (context, value, child) {
            return _artistNameText(value.playingSong);
          },
        ),
        const Padding(padding: EdgeInsets.only(top: 40)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Consumer2<PlayerHandler, PlaylistController>(
              builder: (context, value, playlists, child) {
                return IconButton(
                  onPressed: () async {
                    PlaylistData playlistData = playlists.playlists.firstWhere(
                      (element) => element.id == 1,
                    );

                    if (value.playingSong != null) {
                      if (_isLiked(value.playingSong)) {
                        await playlists.removeSong(
                          playlistData,
                          value.playingSong!,
                        );
                      } else {
                        await playlists.addSong(
                          playlistData,
                          value.playingSong!,
                        );
                      }
                    }
                  },
                  icon: (_isLiked(value.playingSong))
                      ? Icon(
                          Icons.favorite,
                          color: Theme.of(context).primaryColor,
                        )
                      : const Icon(Icons.favorite_border),
                );
              },
            ),
            previousSongButton(),
            Consumer<PlayerHandler>(
              builder: (context, value, child) {
                return pauseSongButton(value.isPaused);
              },
            ),
            nextSongButton(),
            shuffleSongButton(),
          ],
        ),
      ],
    );
  }

  Widget _closedNormalWidget() {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! > 0) {
            PlayerData.instance.handler.next();
          } else {
            PlayerData.instance.handler.previous();
          }
        }
      },
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
              trailing: pauseSongButton(value.isPaused),
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
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! > 0) {
              PlayerData.instance.handler.next();
            } else {
              PlayerData.instance.handler.previous();
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
                  trailing: pauseSongButton(value.isPaused),
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
          try {
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
              widget.onEvent!(_opened);
            }
          } catch (_) {}

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
                  color: (_opened)
                      ? Theme.of(context).primaryColor.withAlpha(50)
                      : Theme.of(context).primaryColor.withAlpha(50),
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
                          duration: const Duration(seconds: 1),
                          reverseDuration: const Duration(milliseconds: 100),
                          child: (_opened)
                              ? _openedLargeWidget()
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
        try {
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
            widget.onEvent!(_opened);
          }
        } catch (_) {}
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
                color: Theme.of(context).primaryColor.withAlpha(50),
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
                        duration: const Duration(seconds: 1),
                        reverseDuration: const Duration(milliseconds: 100),
                        child: (_opened)
                            ? _openedNormalWidget()
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
