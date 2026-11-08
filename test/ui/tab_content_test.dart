import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/ui/core/tab_content.dart';

void main() {
  testWidgets('switches immediately, builds lazily, and preserves tab state', (
    tester,
  ) async {
    final selected = ValueNotifier(0);
    addTearDown(selected.dispose);
    var secondBuilds = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<int>(
          valueListenable: selected,
          builder: (context, index, _) => TabContent(
            index: index,
            children: [
              const _CounterTab(),
              Builder(
                builder: (_) {
                  secondBuilds++;
                  return const Text('Second tab');
                },
              ),
            ],
          ),
        ),
      ),
    );
    expect(secondBuilds, 0);
    await tester.tap(find.text('Count: 0'));
    await tester.pump();
    selected.value = 1;
    await tester.pump();
    expect(find.text('Second tab'), findsOneWidget);
    expect(secondBuilds, 1);
    selected.value = 0;
    await tester.pump();
    expect(find.text('Count: 1'), findsOneWidget);
  });
}

class _CounterTab extends StatefulWidget {
  const _CounterTab();
  @override
  State<_CounterTab> createState() => _CounterTabState();
}

class _CounterTabState extends State<_CounterTab> {
  int count = 0;
  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(
      onPressed: () => setState(() => count++),
      child: Text('Count: $count'),
    ),
  );
}
