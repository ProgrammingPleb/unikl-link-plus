import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:new_unikl_link/types/settings/data.dart';
import 'package:new_unikl_link/utils/update/version_data.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateData {
  String latestVersion = "";
  bool isLatest = true;
  bool isDownloaded = false;
  String url = "";
  String appBranch = "stable";
  String? changelog;
  File? payloadFile;

  UpdateData(String oldVersion, VersionData newData, String? appBranch) {
    if (appBranch != null) {
      this.appBranch = appBranch;
    }

    isLatest = _checkIfLatestVersion(oldVersion, newData);
    if (!isLatest) {
      latestVersion = newData.getLatestVersion(this.appBranch);
      changelog = newData.getLatestChangelog(this.appBranch);
      url = newData.getLatestURL(this.appBranch);
    } else {
      latestVersion = oldVersion;
    }
  }

  bool _checkIfLatestVersion(String sOldVersion, VersionData vNewVersion) {
    bool stableBuild = true;
    bool hotfixBuild;
    bool devBuild;
    bool canaryBuild;
    String cOldVersion = sOldVersion;
    List<int> newVersion;

    if (hotfixBuild = sOldVersion.contains("-hotfix")) {
      hotfixBuild = true;
      cOldVersion = sOldVersion.split("-hotfix")[0];
    }
    if (devBuild = sOldVersion.contains("-dev")) {
      stableBuild = false;
      cOldVersion = sOldVersion.split("-dev")[0];
    }
    if (canaryBuild = sOldVersion.contains("-canary")) {
      stableBuild = false;
      cOldVersion = sOldVersion.split("-canary")[0];
    }

    List<int> oldVersion =
        List.from(cOldVersion.split(".").map((e) => int.parse(e)));
    if (appBranch == "dev") {
      newVersion = List.from(vNewVersion.dev.version
          .split("-dev")[0]
          .split(".")
          .map((e) => int.parse(e)));
    } else if (appBranch == "canary") {
      newVersion = List.from(vNewVersion.canary.version
          .split("-canary")[0]
          .split(".")
          .map((e) => int.parse(e)));
    } else {
      newVersion = List.from(vNewVersion.stable.version
          .split("-hotfix")[0]
          .split(".")
          .map((e) => int.parse(e)));
    }
    int pos = 0;

    for (int section in newVersion) {
      if (section > oldVersion[pos]) {
        return false;
      }
      pos += 1;
    }

    if (listEquals(oldVersion, newVersion)) {
      if (appBranch == "stable") {
        if ((devBuild || canaryBuild)) {
          return false;
        }
        if (vNewVersion.stable.version.contains("-hotfix")) {
          if (!hotfixBuild) {
            return false;
          }
          int localHotfix = int.parse(sOldVersion.split("-hotfix")[1]);
          int remoteHotfix =
              int.parse(vNewVersion.stable.version.split("-hotfix")[1]);
          if (remoteHotfix > localHotfix) {
            return false;
          }
        }
      }
      if (appBranch == "dev") {
        if (stableBuild || canaryBuild) {
          return false;
        }
        if (int.parse(sOldVersion.split("-dev")[1]) <
            int.parse(vNewVersion.dev.version.split("-dev")[1])) {
          return false;
        }
      }
      if (appBranch == "canary") {
        if (stableBuild || devBuild) {
          return false;
        }
        if (int.parse(sOldVersion.split("-canary")[1]) <
            int.parse(vNewVersion.canary.version.split("-canary")[1])) {
          return false;
        }
      }
    }

    return true;
  }
}

class DownloadData {
  bool success;
  String? filePath;

  DownloadData(this.success, [this.filePath]);
}

Future<UpdateData> checkUpdates(SettingsData settings) {
  Completer<UpdateData> c = Completer();
  Future<PackageInfo> packageInfo = PackageInfo.fromPlatform();
  Future<SharedPreferences> storeFuture = SharedPreferences.getInstance();

  storeFuture.then((store) {
    packageInfo.then((appInfo) {
      http
          .get(Uri.parse("https://pleb.moe/UniKLLinkPlus/version-v2.json"))
          .then((resp) {
        VersionData versionData = VersionData(resp.body);
        UpdateData updateData =
            UpdateData(appInfo.version, versionData, settings.appBranch);
        if (!updateData.isLatest) {
          getExternalStorageDirectory().then((directory) {
            File updateFile = File("${directory!.path}/moe.pleb.unikllinkplus-"
                "${updateData.latestVersion}.apk");
            updateFile.exists().then((exists) {
              if (exists) {
                updateData.isDownloaded = true;
                updateData.payloadFile = updateFile;
              }
              c.complete(updateData);
            });
          });
        } else {
          c.complete(updateData);
        }
      });
    });
  });

  return c.future;
}

Future<DownloadData> downloadUpdatePayload(UpdateData updateData) {
  Completer<DownloadData> c = Completer<DownloadData>();
  Dio dio = Dio();

  getExternalStorageDirectory().then((directory) {
    dio
        .download(
            updateData.url,
            "${directory!.path}/moe.pleb.unikllinkplus-"
            "${updateData.latestVersion}.apk",
            deleteOnError: true)
        .then((value) {
      updateData.payloadFile = File("${directory.path}/moe.pleb.unikllinkplus-"
          "${updateData.latestVersion}.apk");
      c.complete(DownloadData(
          true,
          "${directory.path}/moe.pleb.unikllinkplus-"
          "${updateData.latestVersion}.apk"));
    });
  }).onError((error, stackTrace) {
    c.complete(DownloadData(false));
  });

  return c.future;
}
