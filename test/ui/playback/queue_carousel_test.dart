import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/control/media_control.dart';
import 'package:player/model/play_context.dart';
import 'package:player/ui/playback/queue_carousel.dart';

import '../../control/player_handler_test.dart' show FakeBackend, makeSong;

void main() {
  testWidgets('automatic completion moves the carousel to the playing song', (
    tester,
  ) async {
    final backend = FakeBackend();
    final handler = PlayerHandler.withBackend(backend, (_, _) async {});
    addTearDown(handler.dispose);
    handler.playSongList(
      PlayingContext('Test', ContextType.allSongs, [makeSong(1), makeSong(2)]),
      0,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedBuilder(
            animation: handler,
            builder: (context, _) => QueueCarousel(
              index: handler.getPlayingIndex,
              itemCount: handler.getCompleteQueue.length,
              height: 200,
              itemBuilder: (_, index) =>
                  Text('song ${handler.getCompleteQueue[index].id}'),
              onManualPage: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.widget<PageView>(find.byType(PageView)).controller!.page, 0);
    backend.completionEvents.add(null);
    await tester.pump();
    await tester.pump();
    expect(handler.playingSong!.id, 2);
    expect(tester.widget<PageView>(find.byType(PageView)).controller!.page, 1);
  });
}
