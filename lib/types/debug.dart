import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:new_unikl_link/types/info/student_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DebugService {
  final String _webhookUrl =
      "https://discord.com/api/webhooks/1039532836690088036/cZeEYZ3VRWA_20p"
      "Joa9vu5uEuARhDmWBZ1DaX89jy7Dklx1-xNFkGWT6j8yt_1oK_caO";
  final Future<SharedPreferences> storeFuture;

  DebugService({required this.storeFuture});

  void dataError(String section, String data) {
    DateTime now = DateTime.now();
    DateFormat format = DateFormat("d MMMM yyyy',' h:mma");
    String username = "UniKL Link+";

    storeFuture.then((store) {
      if (store.containsKey("profile")) {
        username =
            StudentData.fromJson(jsonDecode(store.getString("profile")!)).name;
      }

      Map<String, dynamic> webhookData = {
        "username": username,
        "embeds": [
          {
            "title": "New Error!",
            "footer": {
              "text": "Occured on ${format.format(now)}",
            },
            "color": 15548997,
            "description": "This user has experienced an error due to "
                "unexpected data.",
            "fields": [
              {
                "name": "Section",
                "value": section,
                "inline": false,
              },
              {
                "name": "Data",
                "value": data,
                "inline": false,
              }
            ]
          }
        ]
      };

      http.post(
        Uri.parse(_webhookUrl),
        body: jsonEncode(webhookData),
        headers: {"content-type": "application/json"},
      );
    });
  }
}
