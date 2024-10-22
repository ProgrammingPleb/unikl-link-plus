import 'dart:async';
import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:new_unikl_link/pages/attendance/history.dart';
import 'package:new_unikl_link/pages/debug/info.dart';
import 'package:new_unikl_link/pages/home.dart';
import 'package:new_unikl_link/pages/more.dart';
import 'package:new_unikl_link/pages/settings.dart';
import 'package:new_unikl_link/pages/timetable.dart';
import 'package:new_unikl_link/server/query.dart';
import 'package:new_unikl_link/server/urls.dart';
import 'package:new_unikl_link/types/info/student_profile.dart';
import 'package:new_unikl_link/types/settings/data.dart';
import 'package:new_unikl_link/types/settings/reload_data.dart';
import 'package:receive_intent/receive_intent.dart' as rintent;
import 'package:receive_intent/receive_intent.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

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
    WakelockPlus.enable();
  }
}

class UKLLinkPlusApp extends StatelessWidget {
  static final _defaultLightColorScheme =
      ColorScheme.fromSwatch(primarySwatch: Colors.blue);

  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.blue, brightness: Brightness.dark);

  const UKLLinkPlusApp({super.key});

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
            pageTransitionsTheme: const PageTransitionsTheme(
                builders: <TargetPlatform, PageTransitionsBuilder>{
                  TargetPlatform.android: PredictiveBackPageTransitionsBuilder()
                }),
          ),
          darkTheme: ThemeData(
            colorScheme: darkDynamic ?? _defaultDarkColorScheme,
            useMaterial3: true,
            snackBarTheme: const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
                builders: <TargetPlatform, PageTransitionsBuilder>{
                  TargetPlatform.android: PredictiveBackPageTransitionsBuilder()
                }),
          ),
          debugShowCheckedModeBanner: false,
          home: MyHomePage(title: 'UniKL Link+'),
        );
      }),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;
  final Future<SharedPreferences> sharedPrefs = SharedPreferences.getInstance();
  final ECitieURLs eCitieURL = ECitieURLs();
  final ECitieQuery eCitieQ = ECitieQuery();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  List<Widget> pages = [];
  late SettingsData settingsData;
  List<Widget> debugBanner = [];
  List<Widget> debugButton = [];
  final ValueNotifier<int> snackMsg = ValueNotifier(0);
  late StudentData studentData;
  int pageIndex = 0;
  bool hasLoggedOut = false;

  void processIntent(rintent.Intent? intent) {
    const appURI = "uklplus://";

    if (intent != null) {
      if (intent.data == "${appURI}settings") {
        Navigator.of(context)
            .push(MaterialPageRoute<ReloadData>(
                builder: (context) => SettingsPage(
                      prevContext: context,
                      storeFuture: widget.sharedPrefs,
                      settingsData: settingsData,
                    )))
            .then((update) {
          if (update != null) {
            if (update.studentProfile) {
              studentData = update.studentData!;
            }
            if (update.debugInterface) {
              updateDebugInterface();
            }
          }
        });
      }
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    pages = [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: HomePage(
          sharedPrefs: widget.sharedPrefs,
          onReceiveStudentData: (data) {
            studentData = data;
          },
          logoutCheck: () => hasLoggedOut,
        ),
      ),
      SizedBox(),
      SizedBox(),
      SizedBox(),
    ];
    widget.sharedPrefs.then((store) {
      settingsData = SettingsData.withoutFuture(store);
    });
        if (Platform.isAndroid) {
      Future.delayed(const Duration(milliseconds: 1000))
              .then((value) => updateDebugInterface());
        }
    ReceiveIntent.getInitialIntent().then((intent) => processIntent(intent));
    ReceiveIntent.receivedIntentStream
        .listen((intent) => processIntent(intent));
    super.initState();
  }

  void showDownloadProgress(int progress, bool displayed) {
    if (!displayed) {
      snackMsg.value = 0;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SnackContent(snackMsg),
          duration: const Duration(minutes: 30),
        ),
      );
    } else {
      snackMsg.value = progress;
    }
  }

  void updateDebugInterface() {
    setState(() {
      if (settingsData.debugMode || kDebugMode) {
        debugBanner = [
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "You are currently in debug mode!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer),
                ),
              ),
            ),
          )
        ];
        debugButton = [enableDebugTests()];
      } else {
        debugBanner.clear();
        debugButton.clear();
      }
    });
  }

  Widget enableDebugTests() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: FloatingActionButton.extended(
        heroTag: "Debug",
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (builder) => DebugInfoPage(
                storeFuture: widget.sharedPrefs,
                studentData: studentData,
              ),
            ),
          );
        },
        icon: const Icon(Icons.science),
        label: const Column(children: [
          Text("Debug Tests"),
        ]),
      ),
    );
  }

  Future<void> initData() {
    widget.sharedPrefs.then((store) {
      settingsData = SettingsData.withoutFuture(store);
      if (store.containsKey("profile")) {
        studentData =
            StudentData.fromJson(jsonDecode(store.getString("profile")!));
      }
    });

    return checkToken(storeFuture: widget.sharedPrefs).then((status) async {
      if (!status.valid && mounted) {
        if (status.needsRelogin) {
          Navigator.push(
            context,
            MaterialPageRoute<StudentData>(
              builder: (context) => LoginPage(
                storeFuture: widget.sharedPrefs,
                relogin: true,
              ),
            ),
          ).then((data) {
            studentData = data!;
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute<StudentData>(
              builder: (context) => LoginPage(
                storeFuture: widget.sharedPrefs,
              ),
            ),
          ).then((data) {
            studentData = data!;
          });
        }
      } else {
        widget.sharedPrefs.then((store) {
          studentData =
              StudentData.fromJson(jsonDecode(store.getString("profile")!));
        });
      }
    });
  }

  Widget oldMainPage() {
    return Expanded(
      child: Padding(
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
            Column(
              children: [
                MenuEntry(icon: Icons.event_note, label: "Timetable"),
                SizedBox(
                  height: 5,
                ),
                FilledButton(
                  onPressed: () => {},
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      children: [
                        Icon(Icons.event_note),
                        Text("Test Button"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (builder) => TimetablePage(
                              storeFuture: widget.sharedPrefs,
                              settings: settingsData,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.event_note),
                      label: const Column(children: [
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AttendanceHistoryPage(
                              sharedPrefs: widget.sharedPrefs,
                              studentData: studentData,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.date_range),
                      label: const Column(children: [
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SelfAttendancePage(
                              studentData: studentData,
                              storeFuture: widget.sharedPrefs,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Column(children: [
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
                                      storeFuture: widget.sharedPrefs,
                                      settingsData: settingsData,
                                    )))
                            .then((update) {
                          if (update != null) {
                            if (update.studentProfile) {
                              studentData = update.studentData!;
                            }
                            if (update.debugInterface) {
                              updateDebugInterface();
                            }
                          }
                        });
                      },
                      icon: const Icon(Icons.settings),
                      label: const Column(children: [
                        Text("Settings"),
                      ]),
                    ),
                  ),
                  ...debugButton,
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
                                        widget.sharedPrefs.then(
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
                                            .push(
                                          MaterialPageRoute<StudentData>(
                                            builder: (context) => LoginPage(
                                                storeFuture:
                                                    widget.sharedPrefs),
                                          ),
                                        )
                                            .then((data) {
                                          setState(() {
                                            studentData = data!;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...debugBanner,
          Expanded(
            child: IndexedStack(
              index: pageIndex,
              children: pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: pageIndex,
        onDestinationSelected: (tab) => setState(() {
          if (pages[tab] is SizedBox) {
            switch (tab) {
              case 1:
                pages[tab] = TimetablePage(
                  storeFuture: widget.sharedPrefs,
                  settings: settingsData,
                );
                break;
              case 2:
                pages[tab] = AttendanceHistoryPage(
                  sharedPrefs: widget.sharedPrefs,
                  studentData: studentData,
                );
                break;
              case 3:
                pages[tab] = Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: MoreActionsPage(
                    sharedPrefs: widget.sharedPrefs,
                    settingsData: settingsData,
                    onLogout: () {
                      pageIndex = 0;
                      pages = [
                        SizedBox(),
                        SizedBox(),
                        SizedBox(),
                        SizedBox(),
                      ];
                      hasLoggedOut = true;
                    },
                    onLogin: () {
                      pages = [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                          child: HomePage(
                            sharedPrefs: widget.sharedPrefs,
                            onReceiveStudentData: (data) {
                              studentData = data;
                            },
                            logoutCheck: () => hasLoggedOut,
                          ),
                        ),
                        SizedBox(),
                        SizedBox(),
                        SizedBox(),
                      ];
                      hasLoggedOut = false;
                    },
                  ),
                );
                break;
            }
          }
          pageIndex = tab;
        }),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note),
            label: "Timetable",
          ),
          NavigationDestination(
            icon: Icon(Icons.date_range),
            label: "Attendance",
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            label: "More",
          ),
        ],
      ),
    );
  }
}

class SnackContent extends StatelessWidget {
  final ValueNotifier<int> snackMsg;

  const SnackContent(this.snackMsg, {super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
        valueListenable: snackMsg,
        builder: (_, progress, __) =>
            Text("An update is being downloaded. ($progress% complete)"));
  }
}
