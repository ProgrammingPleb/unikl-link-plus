import 'package:flutter/material.dart';
import 'package:new_unikl_link/utils/update/updater.dart';

Future<bool?> showUpdatePopup(
    {required BuildContext context, required UpdateData updateData}) {
  return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: ((context) => AlertDialog(
            title: Text("Update v${updateData.latestVersion}"),
            content: Text("Changelog:\n\n${updateData.changelog}"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Install")),
            ],
          )));
}
