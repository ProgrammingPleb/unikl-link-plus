import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:new_unikl_link/types/auth.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:new_unikl_link/utils/update/popup.dart';
import 'package:new_unikl_link/utils/token_tools.dart';
import 'package:new_unikl_link/utils/update/checker.dart';
import 'package:new_unikl_link/utils/update/updater.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:new_unikl_link/attendance/history.dart';
import 'package:new_unikl_link/login.dart';
import 'package:new_unikl_link/attendance/self_attendance.dart';
import 'package:new_unikl_link/server/query.dart';
import 'package:new_unikl_link/server/urls.dart';
import 'package:new_unikl_link/timetable.dart';
import 'package:new_unikl_link/types/info/student_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';

Future<void> main() async {
  if (!kDebugMode) {
    await SentryFlutter.init(
      (options) {
        options.dsn =
            'https://b61ac746242b44c390392c098bbbfb1d@o4504158509924352.ingest.'
            'sentry.io/4504158516215808';
        options.tracesSampleRate = 0.4;
      },
      appRunner: () => runApp(const UKLLinkPlusApp()),
    );
  } else {
    runApp(const UKLLinkPlusApp());
  }
}

class UKLLinkPlusApp extends StatelessWidget {
  static final _defaultLightColorScheme =
      ColorScheme.fromSwatch(primarySwatch: Colors.blue);

  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.blue, brightness: Brightness.dark);

  const UKLLinkPlusApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: ((lightDynamic, darkDynamic) {
        return MaterialApp(
          title: 'UniKL Link+',
          theme: ThemeData(
            colorScheme: lightDynamic ?? _defaultLightColorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkDynamic ?? _defaultDarkColorScheme,
            useMaterial3: true,
          ),
          home: MyHomePage(title: 'UniKL Link+'),
        );
      }),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  final Future<SharedPreferences> _store = SharedPreferences.getInstance();
  final ECitieURLs eCitieURL = ECitieURLs();
  final ECitieQuery eCitieQ = ECitieQuery();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String name = "Placeholder Name";
  String id = "Placeholder ID";
  late StudentData studentData;

  @override
  void initState() {
    initData();
    if (Platform.isAndroid) {
      // mainCheckUpdates(context);
    }
    super.initState();
  }

  Future<void> initData() {
    widget._store.then((store) {
      if (store.containsKey("timetable")) {
        store.remove("timetable");
      }
    });

    return checkToken(storeFuture: widget._store).then((status) {
      if (!status.valid) {
        if (status.needsRelogin) {
          Navigator.push(
            context,
            MaterialPageRoute<StudentData>(
              builder: (context) => LoginPage(
                eCitieURL: widget.eCitieURL,
                eCitieQ: widget.eCitieQ,
                storeFuture: widget._store,
                relogin: true,
              ),
            ),
          ).then((data) {
            setState(() {
              studentData = data!;
              name = data.normalizeName();
              id = data.id;
            });
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute<StudentData>(
              builder: (context) => LoginPage(
                eCitieURL: widget.eCitieURL,
                eCitieQ: widget.eCitieQ,
                storeFuture: widget._store,
              ),
            ),
          ).then((data) {
            setState(() {
              studentData = data!;
              name = data.normalizeName();
              id = data.id;
            });
          });
        }
      } else {
        widget._store.then((store) {
          studentData =
              StudentData.fromJson(jsonDecode(store.getString("profile")!));
          setState(() {
            name = studentData.normalizeName();
            id = studentData.id;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 40, 15, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome Back,",
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: id));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            "Your student ID has been copied to the clipboard!")));
                  },
                  child: Text(
                    "Your ID number is: $id",
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                )),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.77,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: FloatingActionButton.extended(
                      heroTag: "Timetable",
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (builder) => TimetablePage(
                                  storeFuture: widget._store,
                                )));
                      },
                      icon: const Icon(Icons.event_note),
                      label: Column(children: const [
                        Text("Timetable"),
                      ]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: FloatingActionButton.extended(
                      heroTag: "AttHistory",
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AttendanceHistoryPage(
                                  storeFuture: widget._store,
                                )));
                      },
                      icon: const Icon(Icons.date_range),
                      label: Column(children: const [
                        Text("Attendance"),
                        Text("History"),
                      ]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: FloatingActionButton.extended(
                      heroTag: "SelfAttend",
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SelfAttendancePage(
                                  eCitieURL: widget.eCitieURL,
                                  eCitieQ: widget.eCitieQ,
                                  studentData: studentData,
                                  storeFuture: widget._store,
                                )));
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: Column(children: const [
                        Text("Self"),
                        Text("Attendance"),
                      ]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: FloatingActionButton.extended(
                      heroTag: "Logout",
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: ((context) => AlertDialog(
                                  title: const Text("Logging Out"),
                                  content: const Text(
                                      "Are you sure you want to log out?"),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text("Cancel")),
                                    TextButton(
                                      onPressed: () {
                                        widget._store.then(
                                          (store) {
                                            store.remove("tokenExpiry");
                                            store.remove("eCitieToken");
                                            store.remove("o365AccessToken");
                                            store.remove("o365RefreshToken");
                                            store.remove("o365TokenExpiryTime");
                                            store.remove("personID");
                                            store.remove("username");
                                            store.remove("password");
                                            store.remove("profile");
                                          },
                                        );
                                        Navigator.of(context).pop();
                                        Navigator.of(context)
                                            .push(MaterialPageRoute<
                                                    StudentData>(
                                                builder: (context) => LoginPage(
                                                    eCitieURL: widget.eCitieURL,
                                                    eCitieQ: widget.eCitieQ,
                                                    storeFuture:
                                                        widget._store)))
                                            .then((data) {
                                          setState(() {
                                            studentData = data!;
                                            name = data.normalizeName();
                                          });
                                        });
                                      },
                                      child: const Text("Confirm"),
                                    )
                                  ],
                                )));
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
