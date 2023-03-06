import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:new_unikl_link/server/urls.dart';
import 'package:new_unikl_link/types/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

DateFormat expiryFormat = DateFormat("dd MM yyyy - HH mm", "en-US");

Future<TokenStatus> checkToken({Future<SharedPreferences>? storeFuture}) {
  Completer<TokenStatus> c = Completer<TokenStatus>();
  storeFuture ??= SharedPreferences.getInstance();
  ECitieURLs eCitieURL = ECitieURLs();
  bool tokenExpired = true;

  storeFuture.then((store) {
    if (store.containsKey("tokenExpiry")) {
      DateTime currentTime = DateTime.now();
      DateTime expiryTime;
      try {
        expiryTime = expiryFormat.parseStrict(store.getString("tokenExpiry")!);

        if (currentTime.isBefore(expiryTime)) {
          tokenExpired = false;
        }
      } catch (e) {
        tokenExpired = true;
      }
    }

    if (tokenExpired) {
      if (!store.containsKey("eCitieToken")) {
        c.complete(TokenStatus.noKey());
      } else {
        http
            .get(Uri.parse(
                eCitieURL.checkToken(store.getString("eCitieToken")!)))
            .then((resp) {
          Map checkData = jsonDecode(resp.body);
          if (checkData["status"] == "0") {
            http
                .get(Uri.parse(eCitieURL.auth(store.getString("username")!,
                    store.getString("password")!)))
                .then((resp) {
              Map<String, dynamic> json = jsonDecode(resp.body);
              if (json["status"] == "0") {
                c.complete(TokenStatus.needsRelogin());
              } else {
                AuthData auth = AuthData.fromJson(jsonDecode(resp.body));
                store.setString("eCitieToken", auth.eCitieToken);
                c.complete(TokenStatus.valid());
              }
            });
          } else {
            c.complete(TokenStatus.valid());
          }
        });
      }
    } else {
      c.complete(TokenStatus.valid());
    }
  });

  return c.future;
}

Future<void> setTokenExpiry({Future<SharedPreferences>? storeFuture}) {
  Completer<void> c = Completer<void>();
  storeFuture ??= SharedPreferences.getInstance();
  DateTime expiryTime = DateTime.now().add(const Duration(minutes: 30));

  storeFuture.then((store) {
    store.setString("tokenExpiry", expiryFormat.format(expiryTime));
  });

  return c.future;
}

class TokenStatus {
  bool valid = false;
  bool needsRelogin = false;

  TokenStatus.noKey();
  TokenStatus.valid() {
    valid = true;
  }
  TokenStatus.needsRelogin() {
    needsRelogin = true;
  }
}
