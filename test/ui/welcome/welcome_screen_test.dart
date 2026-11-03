import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/ui/welcome/welcome_screen.dart';

void main() {
  testWidgets('welcome screen invokes its close callback', (tester) async {
    var closed = false;
    await tester.pumpWidget(
      MaterialApp(home: WelcomeScreen(onWellcomeClose: () => closed = true)),
    );

    expect(find.text('Bienvenid@'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_forward));
    expect(closed, isTrue);
  });

  testWidgets('welcome pages can be navigated without closing the screen', (
    tester,
  ) async {
    var closed = false;
    await tester.pumpWidget(
      MaterialApp(home: WelcomeScreen(onWellcomeClose: () => closed = true)),
    );

    await tester.drag(find.byType(PageView), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(find.text('Escucha canciones'), findsOneWidget);
    expect(closed, isFalse);
  });
}
