import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/control/audio_backend.dart';
import 'package:player/control/media_control.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';
import 'package:player/model/library_metadata.dart';
import 'package:player/model/play_context.dart';
import 'package:player/model/song.dart';

class FakeBackend implements AudioBackend {
  final stateEvents = StreamController<AudioBackendState>.broadcast(sync: true);
  final completionEvents = StreamController<void>.broadcast(sync: true);
  final durationEvents = StreamController<Duration>.broadcast(sync: true);
  final positionEvents = StreamController<Duration>.broadcast(sync: true);
  final files = <String>[];
  bool disposed = false;
  bool failResume = false;
  bool failPlay = false;
  bool stopped = false;
  @override
  AudioBackendState get state => AudioBackendState.paused;
  @override
  Stream<AudioBackendState> get states => stateEvents.stream;
  @override
  Stream<void> get completed => completionEvents.stream;
  @override
  Stream<Duration> get durations => durationEvents.stream;
  @override
  Stream<Duration> get positions => positionEvents.stream;
  @override
  Future<void> initialize() async {}
  @override
  Future<void> playFile(String path) async {
    if (failPlay) throw StateError('unable to play file');
    files.add(path);
  }

  @override
  Future<void> resume() async {
    if (failResume) throw StateError('audio unavailable');
  }

  @override
  Future<void> pause() async {}
  @override
  Future<void> stop() async {
    stopped = true;
  }

  @override
  Future<void> seek(Duration position) async {}
  @override
  Future<void> dispose() async {
    disposed = true;
    await Future.wait([
      stateEvents.close(),
      completionEvents.close(),
      durationEvents.close(),
      positionEvents.close(),
    ]);
  }
}

SongData makeSong(int id) {
  final artists = <ArtistData>[];
  final album = AlbumData(
    const AlbumMetadata(id: 1, album: 'Album'),
    artwork: Uint8List(0),
    songs: [],
    artists: artists,
  );
  return SongData(
    model: SongMetadata(
      id: id,
      data: '/$id.mp3',
      uri: '/$id.mp3',
      title: 'Song',
      duration: 5000,
    ),
    albumModel: album,
    playedTime: Duration.zero,
    artists: artists,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('completion flushes history and stop stops the backend', () async {
    final backend = FakeBackend();
    final saved = <(int, Duration)>[];
    final handler = PlayerHandler.withBackend(
      backend,
      (id, duration) async => saved.add((id, duration)),
    );
    handler.playSongList(
      PlayingContext('Test', ContextType.allSongs, [makeSong(1)]),
      0,
    );
    await Future<void>.delayed(Duration.zero);
    backend.stateEvents.add(AudioBackendState.playing);
    expect(handler.isPaused, isFalse);
    backend.positionEvents.add(const Duration(seconds: 1));
    backend.completionEvents.add(null);
    await Future<void>.delayed(Duration.zero);
    expect(handler.isPaused, isTrue);
    expect(
      handler.playbackState.value.processingState,
      AudioProcessingState.completed,
    );
    expect(saved, [(1, const Duration(seconds: 1))]);
    await handler.stop();
    expect(backend.stopped, isTrue);
    expect(
      handler.playbackState.value.processingState,
      AudioProcessingState.idle,
    );
    handler.dispose();
  });
  test('reports playback failures without claiming playback resumed', () async {
    final backend = FakeBackend()..failResume = true;
    final handler = PlayerHandler.withBackend(backend, (_, _) async {});
    final oldHandler = FlutterError.onError;
    FlutterError.onError = (_) {};
    addTearDown(() => FlutterError.onError = oldHandler);
    addTearDown(handler.dispose);
    await Future<void>.delayed(Duration.zero);
    await handler.play();
    expect(handler.lastError, isA<StateError>());
    expect(handler.isPaused, isTrue);
  });
  test('reports a failed file playback and returns to paused state', () async {
    final backend = FakeBackend()..failPlay = true;
    final handler = PlayerHandler.withBackend(backend, (_, _) async {});
    final oldHandler = FlutterError.onError;
    FlutterError.onError = (_) {};
    addTearDown(() => FlutterError.onError = oldHandler);
    addTearDown(handler.dispose);
    final song = makeSong(1);
    handler.playSongList(
      PlayingContext('Test', ContextType.allSongs, [song]),
      0,
    );
    await Future<void>.delayed(Duration.zero);
    expect(handler.lastError, isA<StateError>());
    expect(handler.isPaused, isTrue);
  });
  test(
    'plays through an injected backend and saves listening history',
    () async {
      final backend = FakeBackend();
      final saved = <(int, Duration)>[];
      final handler = PlayerHandler.withBackend(
        backend,
        (id, duration) async => saved.add((id, duration)),
      );
      final first = makeSong(1);
      final second = makeSong(2);
      handler.playSongList(
        PlayingContext('Test', ContextType.allSongs, [first, second]),
        0,
      );
      await Future<void>.delayed(Duration.zero);
      expect(backend.files, ['/1.mp3']);
      backend.positionEvents.add(const Duration(seconds: 1));
      await handler.next();
      await Future<void>.delayed(Duration.zero);
      expect(backend.files, ['/1.mp3', '/2.mp3']);
      expect(saved, [(1, const Duration(seconds: 1))]);
      backend.positionEvents.add(const Duration(seconds: 1));
      backend.positionEvents.add(const Duration(seconds: 2));
      await handler.flushHistory();
      expect(saved.last, (2, const Duration(seconds: 2)));
      await handler.pause();
      expect(handler.isPaused, isTrue);
      await handler.play();
      expect(handler.isPaused, isFalse);
      handler.dispose();
      expect(backend.disposed, isTrue);
    },
  );
}
