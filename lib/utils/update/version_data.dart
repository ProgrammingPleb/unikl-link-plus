import 'dart:convert';

class VersionData {
  late final Version stable;
  late final Version dev;
  late final Version canary;

  VersionData(String versionResponse) {
    Map<String, dynamic> versionData = jsonDecode(versionResponse);
    stable = Version(versionData["stable"]);
    dev = Version(versionData["dev"]);
    canary = Version(versionData["canary"]);
  }

  String getLatestVersion(String branch) {
    if (branch == "stable") {
      return stable.version;
    }
    if (branch == "dev") {
      return dev.version;
    }
    if (branch == "canary") {
      return canary.version;
    }
    return "";
  }

  String getLatestURL(String branch) {
    if (branch == "stable") {
      return stable.url;
    }
    if (branch == "dev") {
      return dev.url;
    }
    if (branch == "canary") {
      return canary.url;
    }
    return "";
  }

  String getLatestChangelog(String branch) {
    if (branch == "stable") {
      return stable.changelog;
    }
    if (branch == "dev") {
      return dev.changelog;
    }
    if (branch == "canary") {
      return canary.changelog;
    }
    return "";
  }
}

class Version {
  late final String version;
  late final String url;
  late final String changelog;
  late final String checksum;

  Version(Map<String, dynamic> data) {
    version = data["version"]!;
    url = data["url"]!;
    changelog = data["changelog"]!;
    checksum = data["checksum"]!;
  }
}
