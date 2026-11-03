import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:player/control/playback_queue.dart';
import 'package:player/data/dao.dart';
import 'package:player/data/data.dart';
import 'package:player/model/album.dart';
import 'package:player/model/play_context.dart';

import '../model/song.dart';

class PlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler, ChangeNotifier {
  static final PlayerHandler _playerHandler = PlayerHandler.internal();

  final PlayerData data = PlayerData();
  final AudioPlayer player = AudioPlayer(playerId: 'audio_player');
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

  PlayerHandler.internal() {
    player.onPlayerStateChanged.map(_transformEvent).pipe(playbackState);

    _paused = true;
    player.onPlayerComplete.listen(_songFinished);
    player.onDurationChanged.listen(_durationChanged);
    player.onPositionChanged.listen(_positionChanged);

    player.setPlayerMode(PlayerMode.mediaPlayer);
  }

  PlaybackState _transformEvent(PlayerState state) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (player.state == PlayerState.playing) MediaControl.pause,
        if (player.state == PlayerState.paused) MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.playPause
      },
      androidCompactActionIndices: const [0, 1, 2],
      playing: player.state == PlayerState.playing,
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
    try {
      int diff = pos.inSeconds - _position.inSeconds;

      if (_prevDiff == (diff - 1) || _prevDiff == (diff + 1)) {
        _prevDiff = diff;
        _playedTime += const Duration(seconds: 1);
      }

      _position = pos;
      notifyListeners();
    } catch (_) {}
  }

  void addToQueue(SongData data) {
    _queue.add(data);
    notifyListeners();
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
    } catch (_) {}
  }

  void switchShuffleMode(bool shuffle) {
    try {
      _queue.setShuffle(shuffle);
      notifyListeners();
    } catch (_) {}
  }

  // Player controls
  void _playNow(SongData song) {
    try {
      if (_playing != null && _playedTime != Duration.zero) {
        // Save played time
        PlayerDatabase.instance.addSongDuration(_playing!.id, _playedTime);
        _playing!.playedTime += _playedTime;
      }

      _playedTime = Duration.zero;
      _prevDiff = 0;

      _playing = song;
      _paused = false;

      player
          .play(DeviceFileSource(song.model.data))
          .then((_) => player.seek(Duration.zero));

      String? imageUrl = song.albumModel.imageURL;

      Uri file = Uri.file("");

      if (imageUrl != null) {
        file = Uri.parse(imageUrl);

        if (file != Uri.file("")) {
          mediaItem.add(MediaItem(
            id: song.id.toString(),
            title: song.title,
            album: song.album,
            artUri: file,
            artist: song.artist,
            displayTitle: song.title,
            duration: song.duration,
            playable: true,
            extras: {"loadThumbnailUri": true},
          ));
        } else {
          mediaItem.add(MediaItem(
            id: song.id.toString(),
            title: song.title,
            album: song.album,
            artist: song.artist,
            displayTitle: song.title,
            duration: song.duration,
            playable: true,
            extras: {"loadThumbnailUri": true},
          ));
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
            artUri: Uri.file(song.model.uri!, windows: false),
            extras: {"loadThumbnailUri": true},
          ),
        );
      }

      notifyListeners();
    } catch (_) {}
  }

  @override
  Future<void> play() async {
    player.resume();
    _paused = false;
    notifyListeners();
  }

  @override
  Future<void> pause() async {
    player.pause();
    _paused = true;
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
    player.seek(position);
  }

  void previous() async {
    final song = _queue.previous();
    if (song != null) _playNow(song);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}
