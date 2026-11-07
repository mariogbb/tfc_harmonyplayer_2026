import 'package:flutter/widgets.dart';
import 'package:player/data/services/settings/settings_store.dart';

import 'dart:async';

class PlayerSettings extends ChangeNotifier {
  final SettingsStore store;
  Object? lastError;
  bool _disposed = false;
  final Set<Future<void>> _pendingWrites = {};

  void _persist<T>(String key, T value) {
    late final Future<void> pending;
    pending = _write(
      key,
      value,
    ).whenComplete(() => _pendingWrites.remove(pending));
    _pendingWrites.add(pending);
    unawaited(pending);
  }

  Future<void> flush() async {
    await Future.wait(_pendingWrites.toList());
  }

  Future<void> _write<T>(String key, T value) async {
    try {
      await store.write<T>(key, value);
      if (!_disposed && lastError != null) {
        lastError = null;
        notifyListeners();
      }
    } catch (error, stack) {
      lastError = error;
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'settings',
        ),
      );
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // User name

  String? _userName;

  String? get getUserName => _userName;

  void setUserName(String userName) {
    _userName = userName;
    _persist("user_name", userName);
    notifyListeners();
  }

  // App locale

  Locale? _locale;

  Locale? get getAppLocale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    _persist('language', locale.languageCode);

    notifyListeners();
  }

  // Song filter

  late double _filterDuration;

  double get getFilterDuration => _filterDuration;

  void setFilterDuration(double newDuration) {
    _filterDuration = newDuration;

    _persist<double>("filterDuration", newDuration);

    notifyListeners();
  }

  // Smart audio filter

  late bool _smartFilterEnabled;

  bool get isSmartFilterEnabled => _smartFilterEnabled;

  void setSmartFilterEnabled(bool enabled) {
    _smartFilterEnabled = enabled;

    _persist<bool>("smartFilterEnabled", enabled);

    notifyListeners();
  }

  // Show tab labels

  late bool _showTabLabels;

  bool get isShowTabLabel => _showTabLabels;

  void showTabLabels(bool show) {
    _showTabLabels = show;

    _persist<bool>("show_tab_label", show);

    notifyListeners();
  }

  // Show song time labels

  late bool _showSongTimeLabel;

  bool get isShowSongTimeLabel => _showSongTimeLabel;

  void setShowSongTimeLabel(bool show) {
    _showSongTimeLabel = show;

    _persist<bool>("show_songs_time_label", show);
    notifyListeners();
  }

  PlayerSettings(this.store) {
    _filterDuration = store.read<double>("filterDuration", defaultValue: 0)!;
    _smartFilterEnabled = store.read<bool>(
      "smartFilterEnabled",
      defaultValue: true,
    )!;
    _userName = store.read<String>("user_name");
    final language = store.read<String>('language');
    if (language != null && language.isNotEmpty) _locale = Locale(language);
    _showTabLabels = store.read<bool>('show_tab_label', defaultValue: true)!;
    _showSongTimeLabel = store.read<bool>(
      "show_songs_time_label",
      defaultValue: false,
    )!;
  }

  void setDefaultValues() {
    _persist<double>("filterDuration", 0);
    _persist<bool>("smartFilterEnabled", true);
    _showTabLabels = true;
  }
}
