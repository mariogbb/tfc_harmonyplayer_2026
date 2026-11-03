import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/data/data.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/ui/library/albums/albums_tab.dart';
import 'package:player/ui/library/artists/artists_tab.dart';
import 'package:player/ui/library/songs/songs_tab.dart';
import 'package:player/ui/playlists/playlists_tab.dart';
import 'package:provider/provider.dart';

void main() {
  final cases = <(Widget, String)>[
    (const PlayerSongsTab(), 'No song found'),
    (const PlayerAlbumTab(), 'No album found'),
    (const PlayerArtistTab(), 'No artist found'),
    (const PlaylistTab(), 'No playlist found'),
  ];

  for (final (tab, message) in cases) {
    testWidgets('$tab displays its empty state', (tester) async {
      final data = PlayerData.internal();
      addTearDown(data.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: data,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: tab),
          ),
        ),
      );
      expect(find.text(message), findsOneWidget);
    });
  }
}
