import 'package:flutter_test/flutter_test.dart';
import 'package:player/control/listening_time_tracker.dart';

void main() {
  test('counts normal progress but not backward or large forward seeks', () {
    final tracker = ListeningTimeTracker();
    tracker.observe(Duration.zero, const Duration(seconds: 1));
    tracker.observe(const Duration(seconds: 1), const Duration(seconds: 2));
    tracker.observe(const Duration(seconds: 2), const Duration(seconds: 50));
    tracker.observe(const Duration(seconds: 50), const Duration(seconds: 1));
    expect(tracker.take(), const Duration(seconds: 2));
    expect(tracker.take(), Duration.zero);
  });
}
