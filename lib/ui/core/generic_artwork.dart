import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GenericArtwork extends StatelessWidget {
  final ArtworkType type;
  final ArtworkShape shape;
  final int elementId;
  final Uint8List artwork;
  final BoxFit? fit;
  final String? imageUrl;

  const GenericArtwork({
    Key? key,
    required this.type,
    required this.shape,
    required this.elementId,
    required this.artwork,
    this.fit,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String heroId = "";

    if (type == ArtworkType.album) {
      heroId = "albumHero$elementId";
    } else if (type == ArtworkType.artist) {
      heroId = "artistHero$elementId";
    }

    final imageFit = fit ?? BoxFit.fitWidth;
    Widget fallback() => Image.memory(
      artwork,
      width: shape == ArtworkShape.square ? 40 : null,
      fit: imageFit,
    );
    final url = imageUrl;
    final image = url == null || url.isEmpty
        ? fallback()
        : CachedNetworkImage(
            imageUrl: url,
            width: shape == ArtworkShape.square ? 40 : null,
            fit: imageFit,
            placeholder: (_, _) => fallback(),
            errorWidget: (_, _, _) => fallback(),
          );
    final clipped = shape == ArtworkShape.circle
        ? ClipOval(child: image)
        : ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(7.5)),
            child: image,
          );
    return heroId.isEmpty ? clipped : Hero(tag: heroId, child: clipped);
  }
}

enum ArtworkType { album, song, artist }

enum ArtworkShape { circle, square }
