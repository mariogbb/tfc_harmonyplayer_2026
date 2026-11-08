import 'package:fuzzysearch/fuzzysearch.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';
import 'package:player/model/song.dart';

class LibrarySearchResults {
  const LibrarySearchResults({
    required this.songs,
    required this.albums,
    required this.artists,
  });
  final List<SongData> songs;
  final List<AlbumData> albums;
  final List<ArtistData> artists;
}

/// Search unique metadata strings once, then return every corresponding item.
/// Grouping avoids losing or multiplying tracks with identical names.
Future<List<T>> _find<T>(
  List<T> items,
  String query,
  String Function(T) text,
) async {
  final groups = <String, List<T>>{};
  for (final item in items) {
    final key = text(item).trim().toLowerCase();
    if (key.isNotEmpty) (groups[key] ??= []).add(item);
  }
  if (groups.isEmpty) return [];
  final matches = await Fuzzy<String>(
    groups.keys.toList(),
    options: FuzzyOptions(
      tokenize: true,
      threshold: 0.4,
      isCaseSensitive: false,
    ),
  ).search(query.toLowerCase());
  return [for (final match in matches) ...?groups[match.item]];
}

Future<LibrarySearchResults> searchLibrary({
  required String query,
  required List<SongData> songs,
  required List<AlbumData> albums,
  required List<ArtistData> artists,
}) async {
  final normalized = query.trim();
  if (normalized.isEmpty) {
    return const LibrarySearchResults(songs: [], albums: [], artists: []);
  }
  final results = await Future.wait<Object>([
    _find(
      songs,
      normalized,
      (song) => '${song.title} ${song.artist} ${song.album}',
    ),
    _find(albums, normalized, (album) => '${album.name} ${album.artist}'),
    _find(artists, normalized, (artist) => artist.name),
  ]);
  return LibrarySearchResults(
    songs: results[0] as List<SongData>,
    albums: results[1] as List<AlbumData>,
    artists: results[2] as List<ArtistData>,
  );
}
