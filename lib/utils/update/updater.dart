import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_unikl_link/types/settings/data.dart';
import 'package:new_unikl_link/utils/update/verify.dart';
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
  String updateURL = kDebugMode
      ? "https://pleb.moe/UniKLLinkPlus/version-staging.json"
      : "https://pleb.moe/UniKLLinkPlus/version-v2.json";

  storeFuture.then((store) {
    packageInfo.then((appInfo) {
      http.get(Uri.parse(updateURL)).then((resp) {
        VersionData versionData = VersionData(resp.body);
        UpdateData updateData =
            UpdateData(appInfo.version, versionData, settings.appBranch);
        if (!updateData.isLatest) {
          getExternalStorageDirectory().then((directory) {
            File updateFile = File("${directory!.path}/moe.pleb.unikllinkplus-"
                "${updateData.latestVersion}.apk");
            updateFile.exists().then((exists) {
              if (exists) {
                getFileSha256(updateFile.path).then((value) {
                  Version version = versionData.stable;
                  if (settings.appBranch == "dev") {
                    version = versionData.dev;
                  }
                  if (settings.appBranch == "canary") {
                    version = versionData.canary;
                  }

                  if (value.toString() == version.checksum) {
                    updateData.isDownloaded = true;
                    updateData.payloadFile = updateFile;
                  } else {
                    updateFile.deleteSync();
                  }
                  c.complete(updateData);
                });
              } else {
                c.complete(updateData);
              }
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

Future<DownloadData> downloadUpdatePayload(BuildContext context,
    void Function(int, bool) progressUpdate, UpdateData updateData) {
  Completer<DownloadData> c = Completer<DownloadData>();
  bool displayed = false;
  Dio dio = Dio();

  void showDownloadProgress(int received, int total) {
    int progress = ((received / total) * 100).toInt();
    progressUpdate(progress, displayed);
    displayed = true;
  }

  getExternalStorageDirectory().then((directory) {
    dio
        .download(
            updateData.url,
            "${directory!.path}/moe.pleb.unikllinkplus-"
            "${updateData.latestVersion}.apk",
            options: Options(
              headers: {
                HttpHeaders.acceptEncodingHeader: "*",
              },
            ),
            onReceiveProgress: showDownloadProgress,
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
