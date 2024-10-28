import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsData {
  late final SharedPreferences store;
  int _tokenRefreshHours = 24;
  bool _atAGlanceEnabled = true;
  bool _debugMode = false;
  bool _fastingTimetable = false;

  SettingsData(Future<SharedPreferences> storeFuture) {
    storeFuture.then((store) {
      this.store = store;
      initSettings(store.getString("settings"));
    });
  }

  SettingsData.withoutFuture(this.store) {
    initSettings(store.getString("settings"));
  }

  void initSettings(String? settingsString) {
    if (settingsString == null) {
      updateSettings();
    } else {
      Map<String, dynamic> settingsData = jsonDecode(settingsString);
      processSettings(settingsData);
    }
  }

  @override
  String toString() {
    return "\"At A Glance\" Enabled: $_atAGlanceEnabled, "
        "Debug Mode Enabled: $_debugMode, "
        "Token Refresh Hours: $_tokenRefreshHours, "
        "Fasting Timetable: $_fastingTimetable";
  }

  String toJson() {
    return jsonEncode({
      "atAGlanceEnabled": _atAGlanceEnabled,
      "debugMode": _debugMode,
      "tokenRefreshHours": _tokenRefreshHours,
      "fastingTimetable": _fastingTimetable,
    });
  }

  void processSettings(Map<String, dynamic> settings) async {
    List<String> allSettingsKeys = [
      "appBranch",
      "atAGlanceEnabled",
      "debugMode",
      "tokenRefreshHours",
      "fastingTimetable",
    ];

    if (settings["atAGlanceEnabled"] != null) {
      _atAGlanceEnabled = settings["atAGlanceEnabled"];
    }
    if (settings["tokenRefreshHours"] != null) {
      _tokenRefreshHours = settings["tokenRefreshHours"];
    }
    if (settings["fastingTimetable"] != null) {
      _fastingTimetable = settings["fastingTimetable"];
    }
    if (settings["debugMode"] != null) {
      _debugMode = settings["debugMode"];
    }

    if (!listEquals(settings.keys.toList(), allSettingsKeys)) {
      updateSettings();
    }
  }

  void updateSettings() {
    store.setString("settings", toJson());
  }

  bool get atAGlanceEnabled {
    return _atAGlanceEnabled;
  }

  set atAGlanceEnabled(bool enabled) {
    _atAGlanceEnabled = enabled;
    updateSettings();
  }

  bool get debugMode {
    return _debugMode;
  }

  set debugMode(bool enabled) {
    _debugMode = enabled;
    updateSettings();
  }

  set tokenRefreshHours(int hours) {
    _tokenRefreshHours = hours;
    updateSettings();
  }

  int get tokenRefreshHours {
    return _tokenRefreshHours;
  }

  set fastingTimetable(bool enabled) {
    _fastingTimetable = enabled;
    updateSettings();
  }

  bool get fastingTimetable {
    return _fastingTimetable;
  }
}
