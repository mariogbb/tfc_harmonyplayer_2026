import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:player/data/repositories/playlist_repository.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';
import 'package:player/model/library_metadata.dart';
import 'package:player/model/playlist.dart';
import 'package:player/model/song.dart';
import 'package:player/ui/playlists/playlist_controller.dart';

class FakePlaylistRepository implements PlaylistRepository {
  final events = <String>[];
  bool allowRename = true;
  bool failAdd = false;
  Completer<void>? pendingAdd;

  @override
  Future<List<PlaylistData>> load(List<SongData> songs) async => [
    PlaylistData(id: 1, name: 'Saved', songs: List.of(songs)),
  ];
  @override
  Future<PlaylistData?> create(String name) async =>
      PlaylistData(id: 2, name: name, songs: []);
  @override
  Future<bool> rename(int playlistId, String name) async => allowRename;
  @override
  Future<void> delete(int playlistId) async => events.add('delete:$playlistId');
  @override
  Future<void> addSong(int playlistId, int songId) async {
    events.add('add:$playlistId:$songId');
    if (failAdd) throw StateError('database failure');
    await pendingAdd?.future;
  }

  @override
  Future<void> removeSong(int playlistId, int songId) async =>
      events.add('remove:$playlistId:$songId');
}

SongData makeSong() {
  final artists = <ArtistData>[];
  final album = AlbumData(
    const AlbumMetadata(id: 1, album: 'Album'),
    artwork: Uint8List(0),
    songs: [],
    artists: artists,
  );
  return SongData(
    model: const SongMetadata(id: 5, data: '/song.mp3', title: 'Song'),
    albumModel: album,
    playedTime: Duration.zero,
    artists: artists,
  );
}

void main() {
  test('loads and updates playlist state through the repository', () async {
    final repository = FakePlaylistRepository();
    final controller = PlaylistController(repository);
    addTearDown(controller.dispose);
    var notifications = 0;
    controller.addListener(() => notifications++);
    final song = makeSong();

    await controller.load([]);
    final playlist = controller.playlists.single;
    await controller.addSong(playlist, song);
    await controller.addSong(playlist, song);
    expect(playlist.songs, [song]);
    expect(repository.events, ['add:1:5']);
    await controller.removeSong(playlist, song);
    expect(playlist.songs, isEmpty);
    expect(repository.events.last, 'remove:1:5');

    repository.allowRename = false;
    await controller.rename('Rejected', playlist);
    expect(playlist.name, 'Saved');
    repository.allowRename = true;
    await controller.rename('Renamed', playlist);
    expect(playlist.name, 'Renamed');
    expect(await controller.create('Renamed'), isNull);
    expect((await controller.create('New'))!.name, 'New');
    await controller.delete(playlist);
    expect(controller.playlists.map((p) => p.name), ['New']);
    expect(notifications, 7);
  });

  test('does not notify or change state after disposal', () async {
    final repository = FakePlaylistRepository()..pendingAdd = Completer<void>();
    final controller = PlaylistController(repository);
    final playlist = PlaylistData(id: 1, name: 'Saved', songs: []);
    final operation = controller.addSong(playlist, makeSong());
    controller.dispose();
    repository.pendingAdd!.complete();
    await operation;
    expect(playlist.songs, isEmpty);
  });

  test('retains playlist state and exposes persistence errors', () async {
    final repository = FakePlaylistRepository()..failAdd = true;
    final controller = PlaylistController(repository);
    addTearDown(controller.dispose);
    final oldHandler = FlutterError.onError;
    FlutterError.onError = (_) {};
    addTearDown(() => FlutterError.onError = oldHandler);
    final playlist = PlaylistData(id: 1, name: 'Saved', songs: []);
    await controller.addSong(playlist, makeSong());
    expect(playlist.songs, isEmpty);
    expect(controller.error, isA<StateError>());
  });
}
