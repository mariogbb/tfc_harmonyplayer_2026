import 'package:flutter/material.dart';
import 'package:player/data/data.dart';
import 'package:player/widgets/artist_list_item.dart';
import 'package:provider/provider.dart';
import 'package:player/l10n/app_localizations.dart';

class PlayerArtistTab extends StatelessWidget {
  const PlayerArtistTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScrollController controller = ScrollController();

    return Consumer<PlayerData>(
      builder: (context, value, child) {
        var artistList = value.artistList;

        if (artistList.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.no_artist_found),
          );
        }

        return Scrollbar(
          controller: controller,
          thumbVisibility: true,
          interactive: true,
          child: ListView.builder(
            controller: controller,
            itemCount: artistList.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: ListTile(
                    title: Row(
                      verticalDirection: VerticalDirection.down,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.artist_tab,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          " (${value.artistList.length})",
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ArtistListItem(artist: artistList[index - 1]);
            },
          ),
        );
      },
    );
  }
}
