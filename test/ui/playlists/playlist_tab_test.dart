import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/data/repositories/playlist_repository.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/model/playlist.dart';
import 'package:player/ui/playlists/playlist_controller.dart';
import 'package:player/ui/playlists/playlists_tab.dart';
import 'package:provider/provider.dart';

class FakePlaylistRepository implements PlaylistRepository {
  final renames = <(int, String)>[];
  bool allowRename = true;
  @override
  Future<PlaylistData?> create(String name) async =>
      PlaylistData(id: 8, name: name, songs: []);
  @override
  Future<bool> rename(int playlistId, String name) async {
    renames.add((playlistId, name));
    return allowRename;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('renames through the menu and protects liked songs by ID', (
    tester,
  ) async {
    final repository = FakePlaylistRepository();
    final playlist = PlaylistData(id: 1, name: 'Liked songs', songs: []);
    final controller = PlaylistController(repository, playlists: [playlist]);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: PlaylistTab()),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rename playlist'));
    await tester.pumpAndSettle();
    expect(find.text('Liked songs'), findsWidgets);
    await tester.enterText(find.byType(TextFormField), '  Favorites  ');
    await tester.tap(find.text('Rename playlist'));
    await tester.pumpAndSettle();
    expect(repository.renames, [(1, 'Favorites')]);
    expect(find.text('Favorites'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    final deleteItem = tester.widget<PopupMenuItem<int>>(
      find.ancestor(
        of: find.text('Delete playlist'),
        matching: find.byType(PopupMenuItem<int>),
      ),
    );
    expect(deleteItem.enabled, isFalse);
  });

  testWidgets(
    'rename validates empty names and keeps dialog open on rejection',
    (tester) async {
      final repository = FakePlaylistRepository()..allowRename = false;
      final controller = PlaylistController(
        repository,
        playlists: [PlaylistData(id: 2, name: 'Mix', songs: [])],
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: PlaylistTab()),
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename playlist'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '   ');
      await tester.tap(find.text('Rename playlist'));
      await tester.pumpAndSettle();
      expect(repository.renames, isEmpty);
      await tester.enterText(find.byType(TextFormField), 'Existing');
      await tester.tap(find.text('Rename playlist'));
      await tester.pumpAndSettle();
      expect(repository.renames, [(2, 'Existing')]);
      expect(
        find.text(
          "Couldn't rename the playlist. The name may already be in use.",
        ),
        findsOneWidget,
      );
      expect(controller.playlists.single.name, 'Mix');
    },
  );
  testWidgets('playlist tab reacts directly to controller changes', (
    tester,
  ) async {
    final controller = PlaylistController(FakePlaylistRepository());
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: PlaylistTab()),
        ),
      ),
    );
    expect(find.text('No playlist found'), findsOneWidget);
    await controller.create('My music');
    await tester.pumpAndSettle();
    expect(find.text('My music'), findsOneWidget);
    expect(find.text('No playlist found'), findsNothing);
  });
}
