import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class UpdateData {
  String latestVersion = "";
  bool isLatest = true;
  bool isDownloaded = false;
  String url = "";
  String? changelog;
  File? payloadFile;

  UpdateData(String oldVersion, Map<String, dynamic> newData) {
    url = newData["url"];
    isLatest = _compareVersions(oldVersion, newData["version"]);

    if (isLatest) {
      latestVersion = newData["version"];
      changelog = newData["changelog"];
    } else {
      latestVersion = oldVersion;
    }
  }

  bool _compareVersions(String sOldVersion, String sNewVersion) {
    List<int> oldVersion =
        List.from(sOldVersion.split(".").map((e) => int.parse(e)));
    List<int> newVersion =
        List.from(sNewVersion.split(".").map((e) => int.parse(e)));
    int pos = 0;

    for (int section in newVersion) {
      if (section > oldVersion[pos]) {
        return false;
      }
      pos += 1;
    }

    return true;
  }
}

class DownloadData {
  bool success;
  String? filePath;

  DownloadData(this.success, [this.filePath]);
}

Future<UpdateData> checkUpdates() {
  Completer<UpdateData> c = Completer();
  Future<PackageInfo> packageInfo = PackageInfo.fromPlatform();

  packageInfo.then((appInfo) {
    http
        .get(Uri.parse("https://pleb.moe/UniKLLinkPlus/version.json"))
        .then((resp) {
      Map<String, dynamic> versionData = jsonDecode(resp.body);
      UpdateData updateData = UpdateData(appInfo.version, versionData);
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
