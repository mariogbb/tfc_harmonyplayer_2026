import 'package:flutter/material.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/model/playlist.dart';

import 'package:player/ui/playlists/playlist_controller.dart';
import 'package:provider/provider.dart';

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
                          context.read<PlaylistController>().create(text);
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
                          context.read<PlaylistController>().create(text);
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
    String text = playlist.name;
    String? error;
    bool saving = false;
    final controller = context.read<PlaylistController>();

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.white54,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> submit() async {
              if (saving) return;
              final name = text.trim();
              if (name.isEmpty) {
                setState(
                  () =>
                      error = AppLocalizations.of(context)!.field_cannot_empty,
                );
                return;
              }
              setState(() {
                saving = true;
                error = null;
              });
              final success = await controller.rename(name, playlist);
              if (!context.mounted) return;
              if (success) {
                Navigator.pop(context);
              } else {
                setState(() {
                  saving = false;
                  error = AppLocalizations.of(context)!.playlist_rename_error;
                });
              }
            }

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
                    title: TextFormField(
                      initialValue: playlist.name,
                      enabled: !saving,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.go,
                      maxLength: 50,
                      onFieldSubmitted: (_) => submit(),
                      decoration: InputDecoration(
                        label: Text(AppLocalizations.of(context)!.name),
                        errorText: error,
                      ),
                      onChanged: (value) {
                        setState(() => text = value);
                        setState(() => error = null);
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
                      onPressed: saving ? null : submit,
                      child: Text(
                        AppLocalizations.of(context)!.rename_playlist,
                      ),
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
