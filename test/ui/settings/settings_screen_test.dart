import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/ui/settings/about_screen/about_app_screen.dart';
import 'package:player/ui/settings/settings_screen.dart';

void main() {
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
