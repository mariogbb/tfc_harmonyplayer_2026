import 'package:flutter/widgets.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class PlayerSettings extends ChangeNotifier {
  static final PlayerSettings _playerData = PlayerSettings.internal();

  factory PlayerSettings() {
    return _playerData;
  }

  static PlayerSettings get instance => _playerData;

  // User name

  String? _userName;

  String? get getUserName => _userName;

  void setUserName(String userName) {
    _userName = userName;
    Settings.setValue("user_name", userName);
    notifyListeners();
  }

  // App locale

  Locale? _locale;

  Locale? get getAppLocale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;

    notifyListeners();
  }

  // Song filter

  late double _filterDuration;

  double get getFilterDuration => _filterDuration;

  void setFilterDuration(double newDuration) {
    _filterDuration = newDuration;

    Settings.setValue<double>("filterDuration", newDuration);

    notifyListeners();
  }

  // Smart audio filter

  late bool _smartFilterEnabled;

  bool get isSmartFilterEnabled => _smartFilterEnabled;

  void setSmartFilterEnabled(bool enabled) {
    _smartFilterEnabled = enabled;

    Settings.setValue<bool>("smartFilterEnabled", enabled);

    notifyListeners();
  }

  // Show tab labels

  late bool _showTabLabels;

  bool get isShowTabLabel => _showTabLabels;

  void showTabLabels(bool show) {
    _showTabLabels = show;

    Settings.setValue<bool>("show_tab_label", show);

    notifyListeners();
  }

  // Show song time labels

  late bool _showSongTimeLabel;

  bool get isShowSongTimeLabel => _showSongTimeLabel;

  void setShowSongTimeLabel(bool show) {
    _showSongTimeLabel = show;

    Settings.setValue<bool>("show_songs_time_label", show);
    notifyListeners();
  }

  PlayerSettings.internal() {
    _filterDuration = Settings.getValue<double>(
      "filterDuration",
      defaultValue: 0,
    )!;
    _smartFilterEnabled = Settings.getValue<bool>(
      "smartFilterEnabled",
      defaultValue: true,
    )!;
    _userName = Settings.getValue<String>("user_name");
    _showTabLabels = true;
    _showSongTimeLabel = Settings.getValue<bool>(
      "show_songs_time_label",
      defaultValue: false,
    )!;
  }

  void setDefaultValues() {
    Settings.setValue<double>("filterDuration", 0);
    Settings.setValue<bool>("smartFilterEnabled", true);
    _showTabLabels = true;
  }
}
