import 'package:audioplayers/audioplayers.dart';

enum AudioBackendState { playing, paused, stopped, completed, disposed }

abstract class AudioBackend {
  AudioBackendState get state;
  Stream<AudioBackendState> get states;
  Stream<void> get completed;
  Stream<Duration> get durations;
  Stream<Duration> get positions;
  Future<void> initialize();
  Future<void> playFile(String path);
  Future<void> resume();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> dispose();
}

class AudioplayersBackend implements AudioBackend {
  AudioplayersBackend() : _player = AudioPlayer(playerId: 'audio_player');
  final AudioPlayer _player;

  AudioBackendState _convert(PlayerState state) => switch (state) {
    PlayerState.playing => AudioBackendState.playing,
    PlayerState.paused => AudioBackendState.paused,
    PlayerState.stopped => AudioBackendState.stopped,
    PlayerState.completed => AudioBackendState.completed,
    PlayerState.disposed => AudioBackendState.disposed,
  };

  @override
  AudioBackendState get state => _convert(_player.state);
  @override
  Stream<AudioBackendState> get states =>
      _player.onPlayerStateChanged.map(_convert);
  @override
  Stream<void> get completed => _player.onPlayerComplete;
  @override
  Stream<Duration> get durations => _player.onDurationChanged;
  @override
  Stream<Duration> get positions => _player.onPositionChanged;
  @override
  Future<void> initialize() => _player.setPlayerMode(PlayerMode.mediaPlayer);
  @override
  Future<void> playFile(String path) => _player.play(DeviceFileSource(path));
  @override
  Future<void> resume() => _player.resume();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> seek(Duration position) => _player.seek(position);
  @override
  Future<void> dispose() => _player.dispose();
}
