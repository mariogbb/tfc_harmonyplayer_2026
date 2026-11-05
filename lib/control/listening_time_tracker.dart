/// Tracks listening time separately from the audio backend and persistence.
class ListeningTimeTracker {
  Duration _listened = Duration.zero;

  void observe(Duration previous, Duration current) {
    final difference = current.inSeconds - previous.inSeconds;
    if (difference > 0 && difference <= 2) {
      _listened += Duration(seconds: difference);
    }
  }

  Duration take() {
    final value = _listened;
    _listened = Duration.zero;
    return value;
  }
}
