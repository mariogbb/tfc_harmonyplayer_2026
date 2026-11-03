import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/screens/welcome_screen/welcome_screen.dart';

void main() {
  testWidgets('welcome screen invokes its close callback', (tester) async {
    var closed = false;
    await tester.pumpWidget(MaterialApp(
      home: WelcomeScreen(onWellcomeClose: () => closed = true),
    ));

    expect(find.text('Bienvenid@'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_forward));
    expect(closed, isTrue);
  });
}
