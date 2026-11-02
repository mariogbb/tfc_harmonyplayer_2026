import 'package:flutter/material.dart';
import 'package:player/widgets/generic_artwork.dart';

class ArtworkCard extends StatelessWidget {
  final String title;
  final String? subTitle;
  final GenericArtwork artwork;

  const ArtworkCard(
      {Key? key, required this.title, required this.artwork, this.subTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            artwork,
            ListTile(
              title: Text(
                title,
                maxLines: 1,
              ),
              subtitle: (subTitle == null)
                  ? null
                  : Text(
                      subTitle!,
                      maxLines: 1,
                    ),
            )
          ],
        ),
      ),
    );
  }
}
