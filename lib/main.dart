import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:new_unikl_link/pages/settings.dart';
import 'package:new_unikl_link/types/settings/data.dart';
import 'package:new_unikl_link/types/settings/reload_data.dart';
import 'package:new_unikl_link/types/subject.dart';
import 'package:new_unikl_link/utils/get_next_or_current_subject.dart';
import 'package:new_unikl_link/utils/token_tools.dart';
import 'package:new_unikl_link/utils/update/checker.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:new_unikl_link/pages/attendance/history.dart';
import 'package:new_unikl_link/pages/login.dart';
import 'package:new_unikl_link/pages/attendance/self_attendance.dart';
import 'package:new_unikl_link/server/query.dart';
import 'package:new_unikl_link/server/urls.dart';
import 'package:new_unikl_link/pages/timetable.dart';
import 'package:new_unikl_link/types/info/student_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:wakelock/wakelock.dart';

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
    Wakelock.enable();
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
            snackBarTheme: const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: darkDynamic ?? _defaultDarkColorScheme,
            useMaterial3: true,
            snackBarTheme: const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
            ),
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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  String name = "Placeholder Name";
  String id = "Placeholder ID";
  late SettingsData settingsData;
  List<Widget> atAGlance = [];
  late StudentData studentData;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    initData().then(
      (value) {
        if (Platform.isAndroid) {
          mainCheckUpdates(context, settingsData);
        }
      },
    );

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && name != "Placeholder Name") {
      updateAtAGlance();
    }
  }

  void updateAtAGlance() {
    if (!settingsData.atAGlanceEnabled) {
      if (atAGlance != []) {
        setState(() {
          atAGlance = [];
        });
      }
      return;
    }

    getNextOrCurrentSubject(widget._store).then(
      (Subject subject) {
        DateTime currentTime = DateTime.now();
        String subjectLocation;
        if (subject.online) {
          subjectLocation = "which is **online**";
        } else {
          subjectLocation =
              "at **room ${subject.roomCode}** (level ${subject.roomLevel})";
        }
        setState(() {
          atAGlance = [
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: MarkdownBody(
                  data: "Today is ${DateFormat.EEEE().format(currentTime)}, "
                      "your next subject is **${subject.name}** "
                      "(${subject.code}) $subjectLocation, and "
                      "${subject.getFormattedDuration(true)}."),
            ),
          ];
        });
      },
    );
  }

  void updateUserDetails(String name, String id) {
    setState(() {
      this.name = name;
      this.id = id;
    });
  }

  Future<void> initData() {
    widget._store.then((store) {
      settingsData = SettingsData.withoutFuture(store);
      if (store.containsKey("profile")) {
        studentData =
            StudentData.fromJson(jsonDecode(store.getString("profile")!));
        updateUserDetails(studentData.normalizeName(), studentData.id);
        updateAtAGlance();
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
            updateAtAGlance();
            studentData = data!;
            updateUserDetails(data.normalizeName(), data.id);
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
            updateAtAGlance();
            studentData = data!;
            updateUserDetails(data.normalizeName(), data.id);
          });
        }
      } else {
        widget._store.then((store) {
          studentData =
              StudentData.fromJson(jsonDecode(store.getString("profile")!));
          updateAtAGlance();
          updateUserDetails(studentData.normalizeName(), studentData.id);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
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
              padding: const EdgeInsets.only(bottom: 20),
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: id));
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "Your student ID has been copied to the clipboard!"),
                    ),
                  );
                },
                child: Text(
                  "Your ID number is: $id",
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            ...atAGlance,
            Expanded(
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.77,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: FloatingActionButton.extended(
                      heroTag: "Timetable",
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (builder) => TimetablePage(
                                      storeFuture: widget._store,
                                    )))
                            .then((value) => updateAtAGlance());
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
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (context) => AttendanceHistoryPage(
                                      storeFuture: widget._store,
                                    )))
                            .then((value) => updateAtAGlance());
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
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (context) => SelfAttendancePage(
                                      eCitieURL: widget.eCitieURL,
                                      eCitieQ: widget.eCitieQ,
                                      studentData: studentData,
                                      storeFuture: widget._store,
                                    )))
                            .then((value) => updateAtAGlance());
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
                      heroTag: "Settings",
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute<ReloadData>(
                                builder: (context) => SettingsPage(
                                      prevContext: context,
                                      storeFuture: widget._store,
                                      settingsData: settingsData,
                                    )))
                            .then((update) {
                          if (update != null) {
                            if (update.studentProfile) {
                              studentData = update.studentData!;
                              updateUserDetails(update.studentData!.name,
                                  update.studentData!.name);
                            }
                            if (update.atAGlance) {
                              updateAtAGlance();
                            }
                          }
                        });
                      },
                      icon: const Icon(Icons.settings),
                      label: Column(children: const [
                        Text("Settings"),
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
