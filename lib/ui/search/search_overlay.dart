import 'dart:async';

import 'package:flutter/material.dart';
import 'package:player/data/data.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/model/play_context.dart';
import 'package:player/ui/core/desktop_content_scope.dart';
import 'package:player/ui/library/albums/album_list_item.dart';
import 'package:player/ui/library/artists/artist_list_item.dart';
import 'package:player/ui/library/library_controller.dart';
import 'package:player/ui/library/songs/song_list_item.dart';
import 'package:player/ui/search/library_search.dart';
import 'package:provider/provider.dart';
import 'package:player/theme_data/neo_style.dart';

enum _Category { all, songs, albums, artists }

class SearchOverlayTab extends StatefulWidget {
  const SearchOverlayTab({super.key});
  @override
  State<SearchOverlayTab> createState() => _SearchOverlayTabState();
}

class _SearchOverlayTabState extends State<SearchOverlayTab> {
  final _controller = TextEditingController();
  Timer? _debounce;
  LibraryController? _library;
  int _generation = 0;
  bool _searching = false;
  _Category _category = _Category.all;
  LibrarySearchResults _results = const LibrarySearchResults(
    songs: [],
    albums: [],
    artists: [],
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final library = context.read<LibraryController>();
    if (!identical(library, _library)) {
      _library?.removeListener(_libraryChanged);
      _library = library;
      library.addListener(_libraryChanged);
      _scheduleSearch();
    }
  }

  void _libraryChanged() => _scheduleSearch();

  void _scheduleSearch() {
    _debounce?.cancel();
    final generation = ++_generation;
    final query = _controller.text.trim();
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _searching = false;
          _results = const LibrarySearchResults(
            songs: [],
            albums: [],
            artists: [],
          );
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _searching = true;
      });
    }
    _debounce = Timer(const Duration(milliseconds: 180), () async {
      final library = _library!;
      try {
        final results = await searchLibrary(
          query: query,
          songs: library.songList,
          albums: library.albumList,
          artists: library.artistList,
        );
        if (!mounted || generation != _generation) return;
        setState(() {
          _results = results;
          _searching = false;
        });
      } catch (error, stack) {
        if (!mounted || generation != _generation) return;
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: 'library search',
          ),
        );
        setState(() {
          _searching = false;
          _results = const LibrarySearchResults(
            songs: [],
            albums: [],
            artists: [],
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _generation++;
    _debounce?.cancel();
    _library?.removeListener(_libraryChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context)!;
    final library = context.watch<LibraryController>();
    final showSongs =
        _category == _Category.all || _category == _Category.songs;
    final showAlbums =
        _category == _Category.all || _category == _Category.albums;
    final showArtists =
        _category == _Category.all || _category == _Category.artists;
    final hasResults =
        (showSongs && _results.songs.isNotEmpty) ||
        (showAlbums && _results.albums.isNotEmpty) ||
        (showArtists && _results.artists.isNotEmpty);
    final playingContext = PlayingContext(
      labels.search,
      ContextType.playlist,
      _results.songs,
    );
    Widget heading(String title, int count) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        '$title · $count',
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
    return Scaffold(
      appBar: DesktopContentScope.isActive(context)
          ? null
          : AppBar(title: Text(labels.search)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onChanged: (_) => _scheduleSearch(),
                    decoration: InputDecoration(
                      labelText: labels.search,
                      hintText: labels.search_hint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _controller.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: MaterialLocalizations.of(context)
                                  .deleteButtonTooltip,
                              onPressed: () {
                                _controller.clear();
                                _scheduleSearch();
                              },
                              icon: const Icon(Icons.close),
                            ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (category, label) in [
                        (_Category.all, labels.search_all),
                        (_Category.songs, labels.songs_tab),
                        (_Category.albums, labels.albums_plural),
                        (_Category.artists, labels.artist_tab),
                      ])
                        DecoratedBox(
                          decoration: NeoStyle.control(
                            context,
                            selected: _category == category,
                          ),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: _category == category,
                            backgroundColor: Colors.transparent,
                            selectedColor: Colors.transparent,
                            side: BorderSide.none,
                            onSelected: (_) =>
                                setState(() => _category = category),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (library.isLoading || _searching)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (library.error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        library.isPermissionDenied
                            ? labels.library_permission_error
                            : labels.library_load_error,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else if (_controller.text.trim().isEmpty || !hasResults)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _controller.text.trim().isEmpty
                            ? labels.search_prompt
                            : labels.search_no_results,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else ...[
                if (showSongs && _results.songs.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: heading(labels.songs_tab, _results.songs.length),
                  ),
                  SliverList.builder(
                    itemCount: _results.songs.length,
                    itemBuilder: (context, index) => SongListItem(
                      data: _results.songs[index],
                      play: (_) => PlayerData.instance.handler.playSongList(
                        playingContext,
                        index,
                      ),
                    ),
                  ),
                ],
                if (showAlbums && _results.albums.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: heading(
                      labels.albums_plural,
                      _results.albums.length,
                    ),
                  ),
                  SliverList.builder(
                    itemCount: _results.albums.length,
                    itemBuilder: (context, index) =>
                        AlbumListItem(data: _results.albums[index]),
                  ),
                ],
                if (showArtists && _results.artists.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: heading(labels.artist_tab, _results.artists.length),
                  ),
                  SliverList.builder(
                    itemCount: _results.artists.length,
                    itemBuilder: (context, index) =>
                        ArtistListItem(artist: _results.artists[index]),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
