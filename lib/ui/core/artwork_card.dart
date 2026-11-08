import 'package:flutter/material.dart';
import 'package:player/ui/core/generic_artwork.dart';
import 'package:player/theme_data/neo_style.dart';

class ArtworkCard extends StatelessWidget {
  final String title;
  final String? subTitle;
  final GenericArtwork artwork;
  final VoidCallback? onTap;

  const ArtworkCard({
    Key? key,
    required this.title,
    required this.artwork,
    this.subTitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: NeoStyle.raised(context, radius: 20),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(aspectRatio: 1, child: artwork),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (subTitle != null)
                  Text(
                    subTitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
