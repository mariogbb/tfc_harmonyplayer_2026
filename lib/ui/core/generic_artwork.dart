import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class GenericArtwork extends StatelessWidget {
  final ArtworkType type;
  final ArtworkShape shape;
  final int elementId;
  final Uint8List artwork;
  final BoxFit? fit;

  const GenericArtwork({
    Key? key,
    required this.type,
    required this.shape,
    required this.elementId,
    required this.artwork,
    this.fit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String heroId = "";

    if (type == ArtworkType.album) {
      heroId = "albumHero$elementId";
    } else if (type == ArtworkType.artist) {
      heroId = "artistHero$elementId";
    }

    return (heroId == "")
        ? (shape == ArtworkShape.circle)
              ? ClipOval(
                  child: Image.memory(artwork, fit: fit ?? BoxFit.fitWidth),
                )
              : ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(7.5)),
                  child: Image.memory(
                    artwork,
                    width: 40,
                    fit: fit ?? BoxFit.fitWidth,
                  ),
                )
        : Hero(
            tag: heroId,
            child: (shape == ArtworkShape.circle)
                ? ClipOval(
                    child: Image.memory(artwork, fit: fit ?? BoxFit.fitWidth),
                  )
                : ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(7.5)),
                    child: Image.memory(
                      artwork,
                      width: 40,
                      fit: fit ?? BoxFit.fitWidth,
                    ),
                  ),
          );
  }
}

enum ArtworkType { album, song, artist }

enum ArtworkShape { circle, square }
