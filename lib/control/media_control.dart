import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:player/control/audio_backend.dart';
import 'package:player/control/playback_queue.dart';
import 'package:player/data/dao.dart';
import 'package:player/model/album.dart';
import 'package:player/model/play_context.dart';

import '../model/song.dart';

class PlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler, ChangeNotifier {
  static final PlayerHandler _playerHandler = PlayerHandler.withBackend(
    AudioplayersBackend(),
    PlayerDatabase.instance.addSongDuration,
  );

  final AudioBackend backend;
  final Future<void> Function(int, Duration) savePlayedTime;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Object? lastError;
  int _errorGeneration = 0;
  bool _disposed = false;

  // Queues and lists to add items to play
  final PlaybackQueue<SongData> _queue = PlaybackQueue();
  SongData? _playing;
  PlayingContext? _playingContext;

  // Playing state variables
  bool _paused = true;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Duration _playedTime = Duration.zero;
  int _prevDiff = 0;

  bool get shuffle => _queue.shuffle;

  static PlayerHandler get instance => _playerHandler;

  bool get isPaused => _paused;
  SongData? get playingSong => _playing;
  Duration get getDuration => _duration;
  Duration get getPosition => _position;
  List<SongData> get getQueuedSongs => _queue.songs;
  List<SongData> get getPlayNextSongs => _queue.playNext;
  List<SongData> get getCompleteQueue => _queue.complete;
  int get getPlayingIndex => _queue.index;
  PlayingContext? get getPlayingContext => _playingContext;

  factory PlayerHandler() {
    return _playerHandler;
  }

  PlayerHandler.withBackend(this.backend, this.savePlayedTime) {
    _subscriptions.add(
      backend.states.listen(
        (state) => playbackState.add(_transformEvent(state)),
        onError: _reportError,
      ),
    );
    _subscriptions.add(
      backend.completed.listen(_songFinished, onError: _reportError),
    );
    _subscriptions.add(
      backend.durations.listen(_durationChanged, onError: _reportError),
    );
    _subscriptions.add(
      backend.positions.listen(_positionChanged, onError: _reportError),
    );
    unawaited(_run(backend.initialize));
  }

  void _reportError(Object error, [StackTrace? stack]) {
    _errorGeneration++;
    lastError = error;
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'audio playback',
      ),
    );
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    final generation = _errorGeneration;
    try {
      await action();
      if (generation == _errorGeneration && lastError != null) {
        lastError = null;
        notifyListeners();
      }
      return true;
    } catch (error, stack) {
      _reportError(error, stack);
      return false;
    }
  }

  PlaybackState _transformEvent(AudioBackendState state) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (state == AudioBackendState.playing) MediaControl.pause,
        if (state != AudioBackendState.playing) MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.playPause,
      },
      androidCompactActionIndices: const [0, 1, 2],
      playing: state == AudioBackendState.playing,
    );
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {}

  void _songFinished(event) {
    next();
  }

  void _durationChanged(Duration dur) {
    _duration = dur;
    _position = Duration.zero;
    notifyListeners();
  }

  void _positionChanged(Duration pos) {
    int diff = pos.inSeconds - _position.inSeconds;

    if (_prevDiff == (diff - 1) || _prevDiff == (diff + 1)) {
      _prevDiff = diff;
      _playedTime += const Duration(seconds: 1);
    }

    _position = pos;
    notifyListeners();
  }

  void addToQueue(SongData data) {
    _queue.add(data);
    notifyListeners();
  }

  void retry() {
    final song = _playing;
    if (song != null) {
      _playNow(song);
    } else {
      unawaited(play());
    }
  }

  void addAlbumToQueue(AlbumData album) {
    _queue.addAll(album.songList);
    notifyListeners();
  }

  void playSongList(PlayingContext playingContext, int index) {
    try {
      final song = _queue.start(playingContext.getSongs, index);
      _playingContext = playingContext;
      _playNow(song);
      notifyListeners();
    } catch (error, stack) {
      _reportError(error, stack);
    }
  }

  void switchShuffleMode(bool shuffle) {
    try {
      _queue.setShuffle(shuffle);
      notifyListeners();
    } catch (error, stack) {
      _reportError(error, stack);
    }
  }

  // Player controls
  void _playNow(SongData song) {
    try {
      if (_playing != null && _playedTime != Duration.zero) {
        // Save played time
        final songId = _playing!.id;
        final playedTime = _playedTime;
        unawaited(_run(() => savePlayedTime(songId, playedTime)));
        _playing!.playedTime += _playedTime;
      }

      _playedTime = Duration.zero;
      _prevDiff = 0;

      _playing = song;
      _paused = false;

      unawaited(
        _run(() async {
          await backend.playFile(song.model.data);
          await backend.seek(Duration.zero);
        }).then((success) {
          if (!success && identical(_playing, song)) {
            _paused = true;
            notifyListeners();
          }
        }),
      );

      String? imageUrl = song.albumModel.imageURL;

      Uri file = Uri.file("");

      if (imageUrl != null) {
        file = Uri.parse(imageUrl);

        if (file != Uri.file("")) {
          mediaItem.add(
            MediaItem(
              id: song.id.toString(),
              title: song.title,
              album: song.album,
              artUri: file,
              artist: song.artist,
              displayTitle: song.title,
              duration: song.duration,
              playable: true,
              extras: {"loadThumbnailUri": true},
            ),
          );
        } else {
          mediaItem.add(
            MediaItem(
              id: song.id.toString(),
              title: song.title,
              album: song.album,
              artist: song.artist,
              displayTitle: song.title,
              duration: song.duration,
              playable: true,
              extras: {"loadThumbnailUri": true},
            ),
          );
        }
      } else {
        mediaItem.add(
          MediaItem(
            id: song.id.toString(),
            title: song.title,
            album: song.album,
            artist: song.artist,
            displayTitle: song.title,
            duration: song.duration,
            playable: true,
            extras: {"loadThumbnailUri": true},
          ),
        );
      }

      notifyListeners();
    } catch (error, stack) {
      _reportError(error, stack);
    }
  }

  @override
  Future<void> play() async {
    if (await _run(backend.resume)) _paused = false;
    notifyListeners();
  }

  @override
  Future<void> pause() async {
    if (await _run(backend.pause)) _paused = true;
    notifyListeners();
  }

  @override
  Future<void> skipToNext() async {
    next();
  }

  @override
  Future<void> skipToPrevious() async {
    previous();
  }

  Future<void> next() async {
    final song = _queue.next();
    if (song != null) _playNow(song);
  }

  List<SongData> getLastPlayingSongs() {
    return _queue.nearby();
  }

  @override
  Future<void> seek(Duration position) async {
    await _run(() => backend.seek(position));
  }

  void previous() async {
    final song = _queue.previous();
    if (song != null) _playNow(song);
  }

  @override
  void dispose() {
    _disposed = true;
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(backend.dispose());
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}
