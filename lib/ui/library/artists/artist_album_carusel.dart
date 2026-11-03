import 'package:flutter/material.dart';
import 'package:player/model/album.dart';

class AlbumCarouselContainer extends StatelessWidget {
  const AlbumCarouselContainer({Key? key, required this.data})
    : super(key: key);

  final AlbumData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, "album", arguments: data);
        },
        child: Padding(
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
                      child: Image.memory(data.artwork, width: 100),
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
