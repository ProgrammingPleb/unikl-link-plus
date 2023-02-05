import 'dart:async';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:new_unikl_link/utils/update/popup.dart';
import 'package:new_unikl_link/utils/update/updater.dart';

Future<void> mainCheckUpdates(BuildContext context) {
    Completer<void> c = Completer();

    checkUpdates().then((updateData) {
      if (!updateData.isLatest) {
        if (updateData.isDownloaded) {
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
                        AndroidIntent intent = AndroidIntent(
                          action: "action_install_package",
                          data: updateData.payloadFile!.path,
                        );
                        intent.launch();
                      }
                    }
                  });
                }),
            duration: const Duration(days: 365),
          ));
        } else {
          downloadUpdatePayload(updateData).then((dlData) {
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
                          AndroidIntent intent = AndroidIntent(
                            action: "action_install_package",
                            data: updateData.payloadFile!.path,
                          );
                          intent.launch();
                        }
                      }
                    });
                  }),
              duration: const Duration(days: 365),
            ));
          });
        }
      }
    });

    return c.future;
  }
