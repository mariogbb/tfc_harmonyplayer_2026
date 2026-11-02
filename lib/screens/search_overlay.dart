import 'package:flutter/material.dart';
import 'package:fuzzysearch/fuzzysearch.dart';
import 'package:player/layout/adaptive_layout.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';
import 'package:player/data/data.dart';
import 'package:player/model/play_context.dart';
import 'package:player/model/song.dart';
import 'package:player/widgets/album_list_item.dart';
import 'package:player/widgets/artist_list_item.dart';
import 'package:player/widgets/song_list.dart';
import 'package:player/l10n/app_localizations.dart';

class SearchOverlayTab extends StatefulWidget {
  const SearchOverlayTab({Key? key}) : super(key: key);

  @override
  State<SearchOverlayTab> createState() => _SearchOverlayTabState();
}

class _SearchOverlayTabState extends State<SearchOverlayTab>
    with AdaptiveElement<SearchOverlayTab> {
  List<SongData> foundSongs = [];
  List<ArtistData> foundArtists = [];
  List<AlbumData> foundAlbums = [];
  List<SearchFilters> activeFilters = [];
  PlayerData playerData = PlayerData();

  String _text = "";

  void _search(String searchString) async {
    setState(() {
      _text = searchString;
    });

    foundAlbums.clear();
    foundArtists.clear();
    foundSongs.clear();

    // Search

    if (activeFilters.contains(SearchFilters.albums)) {
      final fuse = Fuzzy(
          PlayerData.instance.albumList.map((e) => e.name).toList(),
          options: FuzzyOptions(
              tokenize: true, threshold: 0.4, isCaseSensitive: false));

      var result = await fuse.search(_text);

      for (var el in result) {
        PlayerData.instance.albumList
            .where((element) => identical(element.name, el.item))
            .forEach(
              (element) => setState(
                () {
                  foundAlbums.add(element);
                },
              ),
            );
      }
    }

    if (activeFilters.contains(SearchFilters.artists)) {
      final fuse = Fuzzy(
          PlayerData.instance.artistList.map((e) => e.name).toList(),
          options: FuzzyOptions(
              tokenize: true, threshold: 0.4, isCaseSensitive: false));

      var result = await fuse.search(_text);

      for (var el in result) {
        PlayerData.instance.artistList
            .where((element) => identical(element.name, el.item))
            .forEach(
              (element) => setState(
                () {
                  foundArtists.add(element);
                },
              ),
            );
      }
    }

    if (activeFilters.contains(SearchFilters.songs)) {
      final fuse = Fuzzy(
          PlayerData.instance.songList.map((e) => e.title).toList(),
          options: FuzzyOptions(
              tokenize: true, threshold: 0.4, isCaseSensitive: false));

      var result = await fuse.search(_text);

      for (var el in result) {
        PlayerData.instance.songList
            .where((element) => identical(element.title, el.item))
            .forEach(
              (element) => setState(
                () {
                  foundSongs.add(element);
                },
              ),
            );
      }
    }
  }

  Widget _chipRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _chipFilters(context),
    );
  }

  Widget _albumList(BuildContext context) {
    return (foundAlbums.isEmpty)
        ? const Text("")
        : ListView.builder(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemCount: foundAlbums.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  title: Text(AppLocalizations.of(context)!.albums_plural),
                );
              }

              return AlbumListItem(data: foundAlbums[index - 1]);
            },
          );
  }

  Widget _artistList(BuildContext context) {
    return (foundArtists.isEmpty)
        ? const Text("")
        : ListView.builder(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            itemCount: foundArtists.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  title: Text(AppLocalizations.of(context)!.artist_tab),
                );
              }

              return ArtistListItem(artist: foundArtists[index - 1]);
            },
          );
  }

  Widget _songList(BuildContext context) {
    return (foundSongs.isEmpty)
        ? const Center(
            child: Text(""),
          )
        : SongList(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            leading: ListTile(
              title: Text(AppLocalizations.of(context)!.songs_tab),
            ),
            playingContext: PlayingContext(AppLocalizations.of(context)!.search,
                ContextType.playlist, foundSongs));
  }

  List<Widget> _chipFilters(BuildContext context) {
    List<Widget> chips = [];

    List<SearchFilters> filters = [
      SearchFilters.songs,
      SearchFilters.albums,
      SearchFilters.artists
    ];

    List<String> filterText = [
      AppLocalizations.of(context)!.songs_tab,
      AppLocalizations.of(context)!.albums_plural,
      AppLocalizations.of(context)!.artist_tab
    ];

    for (var element in filters) {
      chips.add(
        FilterChip(
          label: Text(filterText[filters.indexOf(element)]),
          checkmarkColor: Theme.of(context).primaryColor,
          onSelected: (value) {
            setState(() {
              if (activeFilters.contains(element)) {
                activeFilters.remove(element);
              } else {
                activeFilters.add(element);
              }
            });
          },
          selected: activeFilters.contains(element),
        ),
      );
    }

    return chips;
  }

  @override
  Widget buildLarge(BuildContext context) {
    return buildNormal(context);
  }

  @override
  Widget buildNormal(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        appBar: AppBar(
          title: TextFormField(
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
            cursorColor: Theme.of(context).highlightColor,
            initialValue: _text,
            textInputAction: TextInputAction.search,
            onChanged: (value) => {
              setState(() {
                _text = value;
                _search(value);
              })
            },
          ),
        ),
        body: ListView(
          shrinkWrap: false,
          children: [
            _chipRow(context),
            if (_text == "") ...[
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.nothing_found,
                  textAlign: TextAlign.center,
                ),
              )
            ] else ...[
              if (foundSongs.isNotEmpty) ...[_songList(context)],
              if (foundArtists.isNotEmpty) ...[_artistList(context)],
              if (foundAlbums.isNotEmpty) ...[_albumList(context)],
            ]
          ],
        ),
      ),
    );
  }
}

enum SearchFilters { albums, songs, artists, playlists }
