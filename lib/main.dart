import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:new_unikl_link/components/debug_banner.dart';
import 'package:new_unikl_link/pages/attendance/history.dart';
import 'package:new_unikl_link/pages/debug/page.dart';
import 'package:new_unikl_link/pages/home.dart';
import 'package:new_unikl_link/pages/more.dart';
import 'package:new_unikl_link/pages/settings.dart';
import 'package:new_unikl_link/pages/timetable.dart';
import 'package:new_unikl_link/server/query.dart';
import 'package:new_unikl_link/server/urls.dart';
import 'package:new_unikl_link/types/info/student_profile.dart';
import 'package:new_unikl_link/types/settings/data.dart';
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
  final ValueNotifier<int> snackMsg = ValueNotifier(0);
  late StudentData studentData;
  int pageIndex = 0;
  bool hasLoggedOut = false;
  bool inDebugMode = false;

  void processIntent(rintent.Intent? intent) {
    const appURI = "uklplus://";

    if (intent != null) {
      if (intent.data == "${appURI}settings") {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SettingsPage(
                  prevContext: context,
                  sharedPrefs: widget.sharedPrefs,
                  settingsData: settingsData,
                  onUpdate: (data) => setState(() {
                    settingsData = data;
                  }),
                )));
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
      setState(() {
        inDebugMode = settingsData.debugMode;
      });
    });
    ReceiveIntent.getInitialIntent().then((intent) => processIntent(intent));
    ReceiveIntent.receivedIntentStream
        .listen((intent) => processIntent(intent));
    super.initState();
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
                sharedPrefs: widget.sharedPrefs,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DebugBanner(enabled: inDebugMode),
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
              case 0:
                pages[tab] = Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: HomePage(
                    sharedPrefs: widget.sharedPrefs,
                    onReceiveStudentData: (data) {
                      studentData = data;
                    },
                    logoutCheck: () => hasLoggedOut,
                  ),
                );
                break;
              case 1:
                pages[tab] = TimetablePage(
                  sharedPrefs: widget.sharedPrefs,
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
                    studentData: studentData,
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
                    onSettingsUpdate: (data) {
                      setState(() {
                        settingsData = data;
                        pages[0] = SizedBox();
                        pages[1] = SizedBox();
                      });
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
