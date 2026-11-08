import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/theme_data/dark_theme.dart';
import 'package:player/theme_data/light_theme.dart';
import 'package:player/theme_data/neo_style.dart';
import 'package:player/theme_data/top_bar_theme.dart';
import 'package:player/ui/core/app_tab_bar.dart';
import 'package:player/ui/core/neo_icon_button.dart';
import 'package:player/ui/core/library_row.dart';

void main() {
  testWidgets('a pressed control uses the recessed surface', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: NeoIconButton(
              icon: Icons.play_arrow,
              onPressed: () {},
              tooltip: 'Play',
            ),
          ),
        ),
      ),
    );
    final surface = find.descendant(
      of: find.byType(NeoIconButton),
      matching: find.byType(AnimatedContainer),
    );
    BoxDecoration decoration() =>
        tester.widget<AnimatedContainer>(surface).decoration! as BoxDecoration;
    expect(decoration().boxShadow!.first.blurStyle, BlurStyle.normal);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byTooltip('Play')),
    );
    await tester.pump(const Duration(milliseconds: 150));
    expect(decoration().boxShadow!.first.blurStyle, BlurStyle.inner);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(decoration().boxShadow!.first.blurStyle, BlurStyle.normal);
  });
  testWidgets(
    'neumorphic controls retain selection and button interaction in both themes',
    (tester) async {
      var count = 0;
      for (final theme in [
        LightTheme.getTheme(NeoStyle.defaultAccent, TopBarTheme.seamless),
        DarkTheme.getTheme(NeoStyle.defaultAccent, TopBarTheme.seamless),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Column(
                children: [
                  NeoIconButton(
                    icon: Icons.shuffle,
                    tooltip: 'Shuffle',
                    selected: true,
                    onPressed: () => count++,
                  ),
                  const LibraryRow(child: ListTile(title: Text('Track'))),
                ],
              ),
            ),
          ),
        );
        final context = tester.element(find.byType(NeoIconButton));
        final selected = NeoStyle.control(context, selected: true);
        final raised = NeoStyle.control(context);
        expect(selected.boxShadow, hasLength(2));
        expect(selected.boxShadow!.first.blurStyle, BlurStyle.inner);
        expect(raised.boxShadow, hasLength(2));
        await tester.tap(find.byTooltip('Shuffle'));
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
      expect(count, 2);
    },
  );
  test('website palette supports light and dark modes and custom accents', () {
    final light = LightTheme.getTheme(
      NeoStyle.defaultAccent,
      TopBarTheme.seamless,
    );
    final dark = DarkTheme.getTheme(
      NeoStyle.defaultAccent,
      TopBarTheme.seamless,
    );
    expect(light.scaffoldBackgroundColor, NeoStyle.lightSurface);
    expect(dark.scaffoldBackgroundColor, NeoStyle.darkSurface);
    expect(dark.primaryColor, NeoStyle.darkDefaultAccent);
    expect(
      DarkTheme.getTheme(Colors.orange, TopBarTheme.rounded).primaryColor,
      Colors.orange,
    );
  });

  testWidgets('neumorphic navigation switches tabs in both themes', (
    tester,
  ) async {
    for (final theme in [
      LightTheme.getTheme(NeoStyle.defaultAccent, TopBarTheme.seamless),
      DarkTheme.getTheme(NeoStyle.defaultAccent, TopBarTheme.seamless),
    ]) {
      await tester.pumpWidget(
        MaterialApp(theme: theme, home: const _NavigationFixture()),
      );
      await tester.tap(find.text('Albums'));
      await tester.pumpAndSettle();
      expect(find.text('Album page'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}

class _NavigationFixture extends StatefulWidget {
  const _NavigationFixture();
  @override
  State<_NavigationFixture> createState() => _NavigationFixtureState();
}

class _NavigationFixtureState extends State<_NavigationFixture>
    with SingleTickerProviderStateMixin {
  late final controller = TabController(length: 2, vsync: this);
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: TabBarView(
      controller: controller,
      children: const [Text('Song page'), Text('Album page')],
    ),
    bottomNavigationBar: AppTabBar(
      controller: controller,
      tabs: const [
        Tab(text: 'Songs'),
        Tab(text: 'Albums'),
      ],
    ),
  );
}
