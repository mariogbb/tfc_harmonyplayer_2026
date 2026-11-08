import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:player/control/media_control.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';
import 'package:player/ui/playlists/playlist_controller.dart';
import 'package:player/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:player/ui/core/neo_icon_button.dart';

/// Persistent desktop playback controls, independent of the mobile sheet.
class DesktopPlayerPanel extends StatelessWidget {
  const DesktopPlayerPanel({
    super.key,
    required this.onAlbum,
    required this.onArtist,
  });
  final ValueChanged<AlbumData> onAlbum;
  final ValueChanged<ArtistData> onArtist;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const Key('desktop_player_panel'),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(left: BorderSide(color: theme.dividerColor)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Consumer2<PlayerHandler, PlaylistController>(
          builder: (context, player, playlists, _) {
            final song = player.playingSong;
            final liked = playlists.playlists.where((p) => p.id == 1);
            final isLiked =
                song != null &&
                liked.isNotEmpty &&
                liked.first.songs.any((item) => item.id == song.id);
            final duration = player.getDuration.inMilliseconds.clamp(
              0,
              1 << 53,
            );
            final position = player.getPosition.inMilliseconds.clamp(
              0,
              duration,
            );
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              children: [
                Text(
                  AppLocalizations.of(context)!.now_playing,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                if (song == null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Icon(
                        Icons.music_note_rounded,
                        size: 64,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.35,
                        ),
                      ),
                    ),
                  )
                else ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: song.albumModel.imageURL == null
                          ? Image.memory(song.artwork, fit: BoxFit.cover)
                          : CachedNetworkImage(
                              imageUrl: song.albumModel.imageURL!,
                              fit: BoxFit.cover,
                              placeholder: (_, _) =>
                                  Image.memory(song.artwork, fit: BoxFit.cover),
                              errorWidget: (_, _, _) =>
                                  Image.memory(song.artwork, fit: BoxFit.cover),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => onAlbum(song.albumModel),
                              child: Text(
                                song.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () => onArtist(song.artistModel),
                              child: Text(
                                song.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      NeoIconButton(
                        onPressed: liked.isEmpty
                            ? null
                            : () => isLiked
                                  ? playlists.removeSong(liked.first, song)
                                  : playlists.addSong(liked.first, song),
                        selected: isLiked,
                        tooltip: AppLocalizations.of(context)!.toggle_like,
                        icon: isLiked ? Icons.favorite : Icons.favorite_border,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: position.toDouble(),
                    max: duration.toDouble(),
                    onChanged: duration == 0
                        ? null
                        : (value) => player.seek(
                            Duration(milliseconds: value.round()),
                          ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        player.getPosition.toStringRepresentation(),
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        player.getDuration.toStringRepresentation(),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      NeoIconButton(
                        onPressed: player.previous,
                        tooltip: AppLocalizations.of(context)!.previous_track,
                        icon: Icons.skip_previous,
                      ),
                      NeoIconButton(
                        onPressed: player.isPaused ? player.play : player.pause,
                        tooltip: player.isPaused
                            ? AppLocalizations.of(context)!.play
                            : AppLocalizations.of(context)!.pause,
                        primary: true,
                        icon: player.isPaused ? Icons.play_arrow : Icons.pause,
                      ),
                      NeoIconButton(
                        onPressed: player.next,
                        tooltip: AppLocalizations.of(context)!.next_track,
                        icon: Icons.skip_next,
                      ),
                      NeoIconButton(
                        onPressed: () =>
                            player.switchShuffleMode(!player.shuffle),
                        selected: player.shuffle,
                        tooltip: AppLocalizations.of(context)!.shuffle,
                        icon: Icons.shuffle,
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
