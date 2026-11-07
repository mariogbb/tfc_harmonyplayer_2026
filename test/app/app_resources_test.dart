import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:player/app/app_resources.dart';
import 'package:player/control/audio_backend.dart';
import 'package:player/control/media_control.dart';
import 'package:player/data/dao.dart';
import 'package:player/data/data.dart';
import 'package:player/data/repositories/artwork_repository.dart';
import 'package:player/data/repositories/music_library_repository.dart';
import 'package:player/data/repositories/playlist_repository.dart';
import 'package:player/data/services/artwork/deezer_artwork_service.dart';
import 'package:player/data/services/artwork/local_artwork_service.dart';
import 'package:player/data/services/settings/settings_store.dart';
import 'package:player/data/settings.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FakeBackend implements AudioBackend {
  bool closed = false;
  @override
  Stream<AudioBackendState> get states => const Stream.empty();
  @override
  Stream<void> get completed => const Stream.empty();
  @override
  Stream<Duration> get durations => const Stream.empty();
  @override
  Stream<Duration> get positions => const Stream.empty();
  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {
    closed = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeClient extends http.BaseClient {
  bool closed = false;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      throw UnimplementedError();
  @override
  void close() {
    closed = true;
  }
}

class FakeMusic implements MusicLibraryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakePlaylists implements PlaylistRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCache implements ArtworkCache {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSearch implements ArtworkSearchService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeStore implements SettingsStore {
  @override
  T? read<T>(String key, {T? defaultValue}) => defaultValue;
  @override
  Future<void> write<T>(String key, T value) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('application owner closes shared resources exactly once', () async {
    sqfliteFfiInit();
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
    );
    final playerDatabase = PlayerDatabase.internal()..database = database;
    final backend = FakeBackend();
    final data = PlayerData.internal()
      ..configureMusicLibrary(FakeMusic())
      ..configurePlaylists(FakePlaylists())
      ..configureArtwork(
        ArtworkRepository(cache: FakeCache(), search: FakeSearch()),
        LocalArtworkService(),
      )
      ..configureRefreshCoordinator(FakeStore())
      ..handler = PlayerHandler.withBackend(backend, (_, _) async {});
    final client = FakeClient();
    final resources = AppResources(
      data: data,
      database: playerDatabase,
      httpClient: client,
      settings: PlayerSettings(FakeStore()),
    );
    await resources.dispose();
    await resources.dispose();
    expect(backend.closed, isTrue);
    expect(client.closed, isTrue);
    expect(database.isOpen, isFalse);
  });
}
