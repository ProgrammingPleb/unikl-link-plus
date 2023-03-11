import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_installer/flutter_app_installer.dart';
import 'package:new_unikl_link/types/settings/data.dart';
import 'package:new_unikl_link/utils/update/popup.dart';
import 'package:new_unikl_link/utils/update/updater.dart';

Future<void> mainCheckUpdates(BuildContext context, SettingsData settings) {
  Completer<void> c = Completer();

  checkUpdates(settings).then((updateData) {
    if (!updateData.isLatest) {
      if (updateData.isDownloaded) {
        updateSnackBar(context, updateData);
      } else {
        downloadUpdatePayload(updateData).then((dlData) {
          updateSnackBar(context, updateData);
        });
      }
    }
  });

  return c.future;
}

void updateSnackBar(BuildContext context, UpdateData updateData) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: const Text("An app update is now available!"),
    action: SnackBarAction(
        label: "Install",
        onPressed: () {
          showUpdatePopup(context: context, updateData: updateData)
              .then((confirmed) {
            confirmed ??= false;
            if (confirmed) {
              if (updateData.payloadFile != null) {
                FlutterAppInstaller.installApk(
                        filePath: updateData.payloadFile!.path)
                    .then((value) => updateSnackBar(context, updateData));
              }
            } else {
              updateSnackBar(context, updateData);
            }
          });
        }),
    duration: const Duration(days: 365),
  ));
}
