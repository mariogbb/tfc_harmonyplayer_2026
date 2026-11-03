import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/app/startup_app.dart';

void main() {
  testWidgets(
    'shows progress and passes the initialization result to the app',
    (tester) async {
      final initialization = Completer<bool>();
      await tester.pumpWidget(
        StartupApp(
          initialize: () => initialization.future,
          appBuilder: (showWelcome) =>
              MaterialApp(home: Text('welcome: $showWelcome')),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      initialization.complete(true);
      await tester.pumpAndSettle();
      expect(find.text('welcome: true'), findsOneWidget);
    },
  );

  testWidgets('shows an actionable error without exposing the exception', (
    tester,
  ) async {
    final initialization = Completer<bool>();
    final previous = FlutterError.onError;
    final reports = <FlutterErrorDetails>[];
    FlutterError.onError = reports.add;
    addTearDown(() => FlutterError.onError = previous);
    await tester.pumpWidget(
      StartupApp(
        initialize: () => initialization.future,
        appBuilder: (_) => const MaterialApp(home: Text('Unexpected success')),
      ),
    );
    initialization.completeError(StateError('sensitive database path'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Harmony Player could not start.'),
      findsOneWidget,
    );
    expect(find.textContaining('sensitive database path'), findsNothing);
    expect(find.text('Unexpected success'), findsNothing);
    expect(reports.single.library, 'application startup');
  });
}
