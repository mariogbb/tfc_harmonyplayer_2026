import 'package:flutter/material.dart';
import 'package:player/ui/library/library_controller.dart';
import 'package:player/ui/library/artists/artist_list_item.dart';
import 'package:player/ui/core/library_header.dart';
import 'package:provider/provider.dart';
import 'package:player/l10n/app_localizations.dart';

class PlayerArtistTab extends StatelessWidget {
  const PlayerArtistTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScrollController controller = ScrollController();

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
                return LibraryHeader(
                  title: AppLocalizations.of(context)!.artist_tab,
                  count: artistList.length,
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
