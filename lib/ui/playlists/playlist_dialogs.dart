import 'package:flutter/material.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/model/playlist.dart';

import 'package:player/data/data.dart';

class PlaylistDialogs {
  static void createPlaylistPopup(BuildContext context) {
    String text = "";
    bool error = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.white54,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.create_playlist,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  ListTile(
                    title: TextField(
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.go,
                      maxLength: 50,
                      onSubmitted: (value) {
                        if (text.isEmpty) {
                          setState(() => error = true);
                        } else {
                          PlayerData().createPlaylist(text);
                          Navigator.pop(context);
                        }
                      },
                      decoration: InputDecoration(
                        label: Text(AppLocalizations.of(context)!.name),
                        errorText: (error)
                            ? AppLocalizations.of(context)!.field_cannot_empty
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() => text = value);
                        setState(() => error = false);
                      },
                    ),
                  ),
                  ListTile(
                    title: OutlinedButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: const BorderSide(),
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (text.isEmpty) {
                          setState(() => error = true);
                        } else {
                          PlayerData().createPlaylist(text);
                          Navigator.pop(context);
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.create),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void renamePlaylist(BuildContext context, PlaylistData playlist) {
    String text = "";
    bool error = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.white54,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.new_name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  ListTile(
                    title: TextField(
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.go,
                      maxLength: 50,
                      onSubmitted: (value) {
                        if (text.isEmpty) {
                          setState(() => error = true);
                        } else {
                          PlayerData().renamePlaylist(text, playlist);
                          Navigator.pop(context);
                        }
                      },
                      decoration: InputDecoration(
                        label: Text(AppLocalizations.of(context)!.name),
                        errorText: (error)
                            ? AppLocalizations.of(context)!.field_cannot_empty
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() => text = value);
                        setState(() => error = false);
                      },
                    ),
                  ),
                  ListTile(
                    title: OutlinedButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: const BorderSide(),
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (text.isEmpty) {
                          setState(() => error = true);
                        } else {
                          PlayerData().renamePlaylist(text, playlist);
                          Navigator.pop(context);
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.create),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
