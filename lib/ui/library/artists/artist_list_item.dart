import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:player/ui/core/adaptive_layout.dart';
import 'package:player/model/artist.dart';

class ArtistListItem extends StatelessAdaptiveLayout {
  const ArtistListItem({Key? key, required this.artist}) : super(key: key);

  final ArtistData artist;

  Widget _artistImage(BuildContext context, Axis orientation) {
    return Hero(
      tag: "artistHero${artist.id}",
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: (artist.imageURL == null)
            ? Image.asset(
                "assets/no_artwork_icon.png",
                fit: (orientation == Axis.vertical)
                    ? BoxFit.fitWidth
                    : BoxFit.fitHeight,
              )
            : CachedNetworkImage(
                imageUrl: artist.imageURL!,
                width: MediaQuery.of(context).size.width * 0.1,
                cacheKey: artist.id.toString(),
                fit: (orientation == Axis.vertical)
                    ? BoxFit.fitWidth
                    : BoxFit.fitHeight,
              ),
      ),
    );
  }

  @override
  Widget buildLarge(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.pushNamed(context, "artist", arguments: artist);
      },
      child: ListTile(
        leading: SizedBox(child: _artistImage(context, Axis.horizontal)),
        title: Text(artist.name),
        subtitle: Text("${artist.songList.length} songs"),
      ),
    );
  }

  @override
  Widget buildNormal(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.pushNamed(context, "artist", arguments: artist);
      },
      child: ListTile(
        leading: SizedBox(
          width: 40,
          height: 40,
          child: _artistImage(context, Axis.vertical),
        ),
        title: Text(artist.name),
        subtitle: Text("${artist.songList.length} songs"),
      ),
    );
  }
}
