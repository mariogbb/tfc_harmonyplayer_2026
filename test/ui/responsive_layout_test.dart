import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/data/repositories/artwork_repository.dart';
import 'package:player/data/services/artwork/local_artwork_service.dart';
import 'package:player/data/settings.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/ui/core/library_header.dart';
import 'package:player/ui/core/detail_header.dart';
import 'package:player/ui/home/menu_tab.dart';
import 'package:player/ui/library/library_controller.dart';
import 'package:provider/provider.dart';

import '../data/player_settings_test.dart' show FakeSettingsStore;
import 'library/library_tabs_test.dart'
    show FakeLibraryRepository, FakeArtworkCache, FakeArtworkSearch;

void main() {
  testWidgets('detail header adapts to narrow and wide layouts', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final width in [320.0, 1000.0]) {
      tester.view.physicalSize = Size(width, 800);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DetailHeader(
                title: 'A very long album title',
                subtitle: 'Artist · 12 songs',
                artwork: const ColoredBox(color: Colors.blue),
                action: FilledButton(
                  onPressed: () {},
                  child: const Text('Shuffle play'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('A very long album title'), findsOneWidget);
      expect(find.text('Shuffle play'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets('library heading wraps on narrow screens with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 800),
            textScaler: TextScaler.linear(1.5),
          ),
          child: Scaffold(
            body: LibraryHeader(
              title: 'Playlists',
              count: 1000,
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.text('Playlists'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard lays out on phone and desktop widths', (tester) async {
    final settings = PlayerSettings(FakeSettingsStore());
    final library = LibraryController(
      repository: FakeLibraryRepository(),
      artworkRepository: ArtworkRepository(
        cache: FakeArtworkCache(),
        search: FakeArtworkSearch(),
      ),
      localArtwork: LocalArtworkService(),
    );
    addTearDown(settings.dispose);
    addTearDown(library.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    for (final size in [const Size(320, 700), const Size(1200, 800)]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: settings),
            ChangeNotifierProvider.value(value: library),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: PlayerMenuTab()),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(PlayerMenuTab), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
