import 'package:player/control/media_control.dart';
import 'package:player/data/data.dart';
import 'package:player/data/dao.dart';
import 'package:http/http.dart' as http;
import 'package:player/data/settings.dart';

/// Owns services created during bootstrap, independently of the home screen.
class AppResources {
  AppResources({
    required this.data,
    required this.database,
    required this.httpClient,
    required this.settings,
  });

  static late AppResources instance;
  final PlayerData data;
  final PlayerDatabase database;
  final http.Client httpClient;
  final PlayerSettings settings;
  bool _disposed = false;

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    data.refreshCoordinator.dispose();
    final PlayerHandler handler = data.handler;
    try {
      await handler.stop();
      await handler.flushHistory();
    } finally {
      handler.dispose();
      try {
        await handler.backendClosed;
      } finally {
        data.dispose();
        await settings.flush();
        settings.dispose();
        httpClient.close();
        await database.database.close();
      }
    }
  }
}
