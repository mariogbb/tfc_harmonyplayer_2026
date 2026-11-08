import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/ui/core/desktop_navigation.dart';
import 'package:player/ui/core/harmony_mark.dart';

void main() {
  testWidgets('desktop sidebar shows labels and selects tabs', (tester) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => DesktopNavigation(
              expanded: true,
              selectedIndex: selected,
              onSelected: (index) => setState(() => selected = index),
              tabs: const [
                Tab(text: 'Home', icon: Icon(Icons.home)),
                Tab(text: 'Albums', icon: Icon(Icons.album)),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.text('Harmony'), findsOneWidget);
    expect(find.byType(HarmonyMark), findsOneWidget);
    expect(find.text('Albums'), findsOneWidget);
    await tester.tap(find.text('Albums'));
    await tester.pump();
    expect(selected, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact sidebar still exposes a tooltip and selection', (
    tester,
  ) async {
    var selected = -1;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DesktopNavigation(
            expanded: false,
            selectedIndex: 0,
            onSelected: (index) => selected = index,
            tabs: const [
              Tab(text: 'Home', icon: Icon(Icons.home)),
              Tab(text: 'Albums', icon: Icon(Icons.album)),
            ],
          ),
        ),
      ),
    );
    expect(find.byTooltip('Albums'), findsOneWidget);
    expect(find.byType(HarmonyMark), findsOneWidget);
    await tester.tap(find.byIcon(Icons.album));
    expect(selected, 1);
  });
}
