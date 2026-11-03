import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/data/repositories/playlist_repository.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/model/playlist.dart';
import 'package:player/ui/playlists/playlist_controller.dart';
import 'package:player/ui/playlists/playlists_tab.dart';
import 'package:provider/provider.dart';

class FakePlaylistRepository implements PlaylistRepository {
  @override
  Future<PlaylistData?> create(String name) async =>
      PlaylistData(id: 8, name: name, songs: []);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
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
