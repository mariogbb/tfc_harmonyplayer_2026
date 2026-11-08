import 'package:flutter/material.dart';

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/ui/settings/about_screen/about_app_screen.dart';
import 'package:player/ui/settings/settings_screen.dart';
import 'package:player/ui/settings/look_and_feel/look_and_feel.dart';
import 'package:player/ui/settings/settings_section.dart';
import 'package:player/data/settings.dart';
import 'package:player/theme_data/theme_provider.dart';
import 'package:player/theme_data/top_bar_theme.dart';
import 'package:provider/provider.dart';

import '../../data/player_settings_test.dart' show FakeSettingsStore;

void main() {
  testWidgets(
    'about displays the email directly and opens mail without a dialog',
    (tester) async {
      Uri? requested;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AboutAppScreen(
            launchEmail: (uri) async {
              requested = uri;
              return true;
            },
          ),
        ),
      );
      expect(find.text('mario.besada.dev@gmail.com'), findsOneWidget);
      expect(find.text('Changelog'), findsNothing);
      await tester.tap(find.text('mario.besada.dev@gmail.com'));
      await tester.pump();
      expect(requested.toString(), 'mailto:mario.besada.dev@gmail.com');
      expect(find.byType(Dialog), findsNothing);
    },
  );
  testWidgets('appearance controls persist values and apply theme changes', (
    tester,
  ) async {
    final store = FakeSettingsStore();
    final settings = PlayerSettings(store);
    final theme = ThemeProvider(store);
    addTearDown(settings.dispose);
    addTearDown(theme.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: theme),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LookAndFeelScreen(),
        ),
      ),
    );
    await tester.tap(find.text('Accent color'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '#123456');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(theme.selectedPrimaryColor.toARGB32(), 0xff123456);
    expect(store.values['accent_color'], '#ff123456');
    await tester.scrollUntilVisible(find.text('App bar theme'), 250);
    final choice = find
        .ancestor(of: find.text('App bar theme'), matching: find.byType(Column))
        .first;
    final dropdown = find.descendant(
      of: choice,
      matching: find.byType(DropdownButtonFormField<TopBarTheme>),
    );
    await tester.ensureVisible(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rounded').last);
    await tester.pumpAndSettle();
    expect(theme.selectedTopBarTheme, TopBarTheme.rounded);
    expect(store.values['topbar_theme'], TopBarTheme.rounded.index);
    await tester.scrollUntilVisible(find.text('Show tabs label'), 250);
    await tester.tap(find.text('Show tabs label'));
    await tester.pump();
    expect(store.values['show_tab_label'], isFalse);
  });
  testWidgets(
    'reload in settings invokes refresh and prevents duplicate taps',
    (tester) async {
      final pending = Completer<void>();
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AppSettingsScreen(
            onReload: () {
              calls++;
              return pending.future;
            },
          ),
        ),
      );
      await tester.ensureVisible(find.text('Reload songs'));
      await tester.tap(find.text('Reload songs'));
      await tester.pump();
      expect(calls, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      pending.complete();
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );
  testWidgets('settings overview adapts its categories to window width', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final width in [400.0, 1200.0]) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AppSettingsScreen(),
        ),
      );
      await tester.pump();
      final first = tester.getTopLeft(find.text('Look and feel'));
      final second = tester.getTopLeft(find.text('Song settings'));
      if (width < 700) {
        expect(second.dy, greaterThan(first.dy));
      } else {
        expect(second.dx, greaterThan(first.dx));
      }
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets('appearance settings have distinct labels and themed sections', (
    tester,
  ) async {
    final store = FakeSettingsStore();
    final settings = PlayerSettings(store);
    final theme = ThemeProvider(store);
    addTearDown(settings.dispose);
    addTearDown(theme.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: theme),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LookAndFeelScreen(),
        ),
      ),
    );
    expect(find.byType(SettingsSection), findsWidgets);
    await tester.ensureVisible(find.text('Show song duration'));
    expect(find.text('Show song duration'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Show tabs label'), 250);
    expect(find.text('Show tabs label'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('settings menu opens the about screen and navigates back', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppSettingsScreen(),
      ),
    );

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Backup'), findsNothing);
    expect(find.byIcon(Icons.settings_backup_restore), findsNothing);
    await tester.ensureVisible(find.text('About'));
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.byType(AboutAppScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(AppSettingsScreen), findsOneWidget);
  });
}
