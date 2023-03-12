import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:new_unikl_link/types/settings/invalid_branch.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsData {
  late final SharedPreferences store;
  String _appBranch = "stable";
  bool _atAGlanceEnabled = true;
  bool _debugMode = false;
  bool _debugPermissible = false;

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
    return "App Branch: $_appBranch, "
        "\"At A Glance\" Enabled: $_atAGlanceEnabled";
  }

  String toJson() {
    return jsonEncode({
      "appBranch": _appBranch,
      "atAGlanceEnabled": _atAGlanceEnabled,
      "debugMode": _debugMode,
    });
  }

  void processSettings(Map<String, dynamic> settings) async {
    List<String> allSettingsKeys = [
      "appBranch",
      "atAGlanceEnabled",
      "debugMode",
    ];

    if (settings["appBranch"] != null) {
      _appBranch = settings["appBranch"];
    }
    if (settings["atAGlanceEnabled"] != null) {
      _atAGlanceEnabled = settings["atAGlanceEnabled"];
    }
    if (settings["debugMode"] != null) {
      PackageInfo versionData = await PackageInfo.fromPlatform();
      if (versionData.version.contains("-canary")) {
        _debugMode = settings["debugMode"];
        _debugPermissible = true;
      } else if (settings["debugMode"]) {
        updateSettings();
      }
      if (kDebugMode) {
        _debugMode = true;
      }
    }

    if (!listEquals(settings.keys.toList(), allSettingsKeys)) {
      updateSettings();
    }
  }

  void updateSettings() {
    store.setString("settings", toJson());
  }

  String get appBranch {
    return _appBranch;
  }

  set appBranch(String branch) {
    if (!["stable", "dev", "canary"].contains(branch)) {
      throw InvalidBranchException(branch);
    }
    _appBranch = branch;
    updateSettings();
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

  bool get debugPermissible {
    return _debugPermissible;
  }
}
