import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:player/control/playback_queue.dart';

void main() {
  test(
    'advances and returns to previous songs without exceeding the queue',
    () {
      final queue = PlaybackQueue<String>();
      expect(queue.start(['a', 'b', 'c'], 0), 'a');
      expect(queue.next(), 'b');
      expect(queue.next(), 'c');
      expect(queue.next(), isNull);
      expect(queue.index, 2);
      expect(queue.previous(), 'b');
      expect(queue.previous(), 'a');
      expect(queue.previous(), 'a');
    },
  );

  test('plays requested songs before continuing the original queue', () {
    final queue = PlaybackQueue<String>();
    queue.start(['a', 'b', 'c'], 0);
    queue.add('x');
    queue.addAll(['y', 'z']);
    expect(queue.complete, ['x', 'y', 'z', 'a', 'b', 'c']);
    expect(queue.next(), 'x');
    expect(queue.next(), 'y');
    expect(queue.next(), 'z');
    expect(queue.next(), 'b');
    expect(queue.playNext, isEmpty);
  });

  test('shuffle retains current song and restores original order', () {
    final queue = PlaybackQueue<String>(random: Random(1));
    queue.start(['a', 'b', 'c', 'd'], 2);
    queue.setShuffle(true);
    expect(queue.shuffle, isTrue);
    expect(queue.songs.first, 'c');
    expect(queue.index, 0);
    expect(queue.songs.toSet(), {'a', 'b', 'c', 'd'});
    queue.setShuffle(false);
    expect(queue.songs, ['a', 'b', 'c', 'd']);
    expect(queue.index, 2);
    expect(queue.next(), 'd');
  });

  test('handles an empty queue, invalid starts, and immutable views', () {
    final queue = PlaybackQueue<String>();
    queue.setShuffle(true);
    expect(queue.next(), isNull);
    expect(queue.previous(), isNull);
    expect(() => queue.start([], 0), throwsRangeError);
    queue.start(['a'], 0);
    expect(() => queue.songs.add('b'), throwsUnsupportedError);
  });

  test('keeps the queue usable when shuffle changes during play-next', () {
    final queue = PlaybackQueue<String>(random: Random(1));
    queue.start(['a', 'b'], 0);
    queue.add('x');
    expect(queue.next(), 'x');
    queue.setShuffle(true);
    expect(queue.songs.first, 'x');
    queue.setShuffle(false);
    expect(queue.index, greaterThanOrEqualTo(0));
    expect(queue.next(), 'b');
  });
}
