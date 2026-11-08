import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/app/startup_app.dart';

void main() {
  testWidgets('shows progress and opens the app after initialization', (
    tester,
  ) async {
    final initialization = Completer<void>();
    await tester.pumpWidget(
      StartupApp(
        initialize: () => initialization.future,
        appBuilder: () => const MaterialApp(home: Text('App ready')),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    initialization.complete();
    await tester.pumpAndSettle();
    expect(find.text('App ready'), findsOneWidget);
  });

  testWidgets('shows an actionable error without exposing the exception', (
    tester,
  ) async {
    final initialization = Completer<void>();
    final previous = FlutterError.onError;
    final reports = <FlutterErrorDetails>[];
    FlutterError.onError = reports.add;
    addTearDown(() => FlutterError.onError = previous);
    await tester.pumpWidget(
      StartupApp(
        initialize: () => initialization.future,
        appBuilder: () => const MaterialApp(home: Text('Unexpected success')),
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
