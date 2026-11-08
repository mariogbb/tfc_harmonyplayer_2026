import 'package:flutter/material.dart';
import 'package:player/model/album.dart';
import 'package:player/theme_data/neo_style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:player/ui/library/library_controller.dart';
import 'package:provider/provider.dart';

class AlbumCarouselContainer extends StatelessWidget {
  const AlbumCarouselContainer({Key? key, required this.data})
    : super(key: key);

  final AlbumData data;

  @override
  Widget build(BuildContext context) {
    context.watch<LibraryController?>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, "album", arguments: data);
        },
        child: Container(
          decoration: NeoStyle.control(context, radius: 18),
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            width: 100,
            height: 175,
            child: DecoratedBox(
              decoration: const BoxDecoration(),
              child: Column(
                children: [
                  Expanded(
                    flex: 8,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(7.5),
                      ),
                      child: data.imageURL == null
                          ? Image.memory(
                              data.artwork,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: data.imageURL!,
                              width: 100,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Image.memory(
                                data.artwork,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                              errorWidget: (_, _, _) => Image.memory(
                                data.artwork,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      data.name,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
