import 'dart:math';

/// Queue state independent of the audio backend and Flutter widgets.
class PlaybackQueue<T> {
  PlaybackQueue({Random? random}) : _random = random ?? Random();

  final Random _random;
  final List<T> _playNext = [];
  List<T> _songs = [];
  List<T> _original = [];
  int _index = 0;
  T? _current;
  bool _shuffle = false;

  List<T> get songs => List.unmodifiable(_songs);
  List<T> get playNext => List.unmodifiable(_playNext);
  int get index => _index;
  bool get shuffle => _shuffle;

  List<T> get complete => [
    ..._songs.take(_songs.isEmpty ? 0 : _index + 1),
    ..._playNext,
    ..._songs.skip(_songs.isEmpty ? 0 : _index + 1),
  ];

  void add(T song) => _playNext.add(song);
  void addAll(Iterable<T> songs) => _playNext.addAll(songs);

  T start(List<T> songs, int index) {
    if (index < 0 || index >= songs.length) {
      throw RangeError.index(index, songs);
    }
    _original = List.of(songs);
    _songs = List.of(songs);
    _index = index;
    _current = _songs[index];
    if (_shuffle) _shuffleSongs();
    return _current as T;
  }

  void setShuffle(bool enabled) {
    if (_shuffle == enabled) return;
    _shuffle = enabled;
    if (_songs.isEmpty || _current == null) return;
    if (enabled) {
      _shuffleSongs();
    } else {
      final history = _songs.take(_index + 1).toList();
      final remaining = _songs.skip(_index + 1).toList();
      final ordered = <T>[];
      for (final song in _original) {
        final index = remaining.indexOf(song);
        if (index >= 0) ordered.add(remaining.removeAt(index));
      }
      _songs = [...history, ...ordered, ...remaining];
    }
  }

  void _shuffleSongs() {
    final history = _songs.take(_index + 1).toList();
    final remaining = _songs.skip(_index + 1).toList()..shuffle(_random);
    _songs = [...history, ...remaining];
  }

  T? next() {
    if (_playNext.isNotEmpty) {
      _current = _playNext.removeAt(0);
      if (_songs.isEmpty) {
        _songs.add(_current as T);
        _index = 0;
      } else {
        _songs.insert(++_index, _current as T);
      }
      return _current;
    }
    if (_index + 1 >= _songs.length) return null;
    _current = _songs[++_index];
    return _current;
  }

  T? previous() {
    if (_songs.isEmpty) return null;
    if (_index > 0) _index--;
    _current = _songs[_index];
    return _current;
  }

  List<T> nearby() {
    final current = _current;
    if (current == null) return [];
    final index = _index;
    final result = <T>[];
    if (index > 0) {
      result.add(_songs[index - 1]);
    }
    result.add(current);
    if (_playNext.isNotEmpty) {
      result.add(_playNext.first);
    } else if (index >= 0 && index + 1 < _songs.length) {
      result.add(_songs[index + 1]);
    }
    return result;
  }
}
