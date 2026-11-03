import 'package:flutter/material.dart';
import 'package:player/ui/library/library_controller.dart';
import 'package:player/ui/library/albums/album_list_item.dart';
import 'package:provider/provider.dart';
import 'package:player/l10n/app_localizations.dart';

class PlayerAlbumTab extends StatefulWidget {
  const PlayerAlbumTab({Key? key}) : super(key: key);

  @override
  PlayerAlbumTabState createState() => PlayerAlbumTabState();
}

class PlayerAlbumTabState extends State<PlayerAlbumTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryController>(
      builder: (context, value, child) {
        if (value.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (value.error != null) {
          return Center(
            child: Text(
              value.isPermissionDenied
                  ? AppLocalizations.of(context)!.library_permission_error
                  : AppLocalizations.of(context)!.library_load_error,
            ),
          );
        }
        var albumList = value.albumList;

        ScrollController controller = ScrollController();

        if (albumList.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.no_album_found),
          );
        }

        return Scrollbar(
          interactive: true,
          controller: controller,
          child: ListView.builder(
            controller: controller,
            itemCount: albumList.length + 1,
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
                          AppLocalizations.of(context)!.albums_tab,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          " (${value.albumList.length})",
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return AlbumListItem(data: albumList[index - 1]);
            },
          ),
        );
      },
    );
  }
}
