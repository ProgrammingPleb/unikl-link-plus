import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:new_unikl_link/components/info_entry.dart';
import 'package:new_unikl_link/pages/login.dart';
import 'package:new_unikl_link/types/info/student_profile.dart';
import 'package:new_unikl_link/types/settings/data.dart';
import 'package:new_unikl_link/types/timetable/timed_subject.dart';
import 'package:new_unikl_link/utils/get_next_or_current_subject.dart';
import 'package:new_unikl_link/utils/normalize.dart';
import 'package:new_unikl_link/utils/token_tools.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final Future<SharedPreferences> sharedPrefs;
  final void Function(StudentData data) onReceiveStudentData;
  final bool Function() logoutCheck;

  const HomePage({
    super.key,
    required this.sharedPrefs,
    required this.onReceiveStudentData,
    required this.logoutCheck,
  });

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final DateFormat currentTimeFormat = DateFormat("h:mma (EEEE, d MMMM)");
  String name = "Placeholder Name";
  String id = "Placeholder ID";
  String date = "12:00am (Thursday, 1 January)";
  TimedSubject nextorCurrentSubject = TimedSubject.empty();
  TimedSubject? nextSubject;
  bool loaded = false;
  late StudentData studentData;
  late SettingsData settingsData;
  Timer? timeTimer;
  Timer? subjectTimer;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    initData().then((loggedIn) async {
      updateTime();
      timeTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
        if (mounted) {
          setState(() {
            updateTime();
          });
        }
      });

      setState(() {
        loaded = true;
      });
      if (loggedIn) {
        updateNextClass();
        subjectTimer = Timer.periodic(Duration(seconds: 5), (timer) {
          if (mounted) {
            setState(() {
              updateNextClass();
            });
          }
        });
      }
      bool tokenValid = await checkLogin();
      if (tokenValid && !loggedIn) {
        subjectTimer = Timer.periodic(Duration(seconds: 5), (timer) {
          if (mounted) {
            setState(() {
              updateNextClass();
            });
          }
        });
      }
    });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (name != "Placeholder Name") {
        initData();
      }
      updateNextClass();
    }
  }

  @override
  void dispose() {
    timeTimer?.cancel();
    subjectTimer?.cancel();
    super.dispose();
  }

  void updateTime() {
    if (widget.logoutCheck()) {
      timeTimer?.cancel();
      subjectTimer?.cancel();
    }
    date = currentTimeFormat.format(DateTime.now());
  }

  Future<void> updateNextClass() async {
    TimedSubject nextorCurrentSubject = await getNextOrCurrentSubject(
      sharedPrefs: widget.sharedPrefs,
      settings: settingsData,
    );
    TimedSubject? nextSubject;
    if (nextorCurrentSubject.isOngoing()) {
      nextSubject = await getNextOrCurrentSubject(
        sharedPrefs: widget.sharedPrefs,
        settings: settingsData,
        nextOnly: true,
      );
    }
    setState(() {
      this.nextorCurrentSubject = nextorCurrentSubject;
      this.nextSubject = nextSubject;
    });
  }

  void updateUserDetails(String name, String id) {
    setState(() {
      this.name = name;
      this.id = id;
    });
  }

  Future<bool> initData() async {
    SharedPreferences store = await widget.sharedPrefs;
    settingsData = SettingsData.withoutFuture(store);
    if (store.containsKey("profile")) {
      studentData =
          StudentData.fromJson(jsonDecode(store.getString("profile")!));
      widget.onReceiveStudentData(studentData);
      updateUserDetails(studentData.normalizeName(), studentData.id);
      return true;
    }
    return false;
  }

  Future<bool> checkLogin() async {
    TokenStatus status = await checkToken(storeFuture: widget.sharedPrefs);
    if (!status.valid && mounted) {
      StudentData? data;
      if (status.needsRelogin) {
        data = await Navigator.push(
          context,
          MaterialPageRoute<StudentData>(
            builder: (context) => LoginPage(
              sharedPrefs: widget.sharedPrefs,
              relogin: true,
            ),
          ),
        );
      } else {
        data = await Navigator.push(
          context,
          MaterialPageRoute<StudentData>(
            builder: (context) => LoginPage(
              sharedPrefs: widget.sharedPrefs,
            ),
          ),
        );
      }

      if (data != null) {
        widget.onReceiveStudentData(data);
        updateUserDetails(data.name, data.id);
        updateNextClass();
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Welcome Back,",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        Text(
          normalizeName(name),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: id));
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text("Your student ID has been copied to the clipboard!"),
              ),
            );
          },
          child: InfoEntry(
            icon: Icon(
              Icons.badge_outlined,
              size: 32,
            ),
            label: "Student ID",
            data: [
              Text(
                id,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 16,
        ),
        InfoEntry(
          icon: Icon(
            Icons.schedule,
            size: 32,
          ),
          label: "Current Time",
          data: [
            Text(
              date,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 16,
        ),
        SubjectEntry(
          subject: nextorCurrentSubject,
          icon:
              nextorCurrentSubject.isOngoing() ? Symbols.timer : Symbols.update,
        ),
        nextSubject != null
            ? SizedBox(
                height: 16,
              )
            : Column(),
        nextSubject != null
            ? SubjectEntry(
                subject: nextSubject!,
                icon: Symbols.update,
              )
            : Column(),
      ],
    );
  }
}

class SubjectEntry extends StatelessWidget {
  final TimedSubject subject;
  final IconData icon;

  const SubjectEntry({
    super.key,
    required this.subject,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InfoEntry(
      icon: Icon(
        icon,
        size: 32,
      ),
      label: subject.isOngoing() ? "Current Class" : "Next Class",
      data: [
        Text(
          subject.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            Text(
              subject.online ? "Online Class" : "Location: ",
            ),
            Text(
              subject.online
                  ? ""
                  : "${subject.roomCode}, "
                      "level ${subject.roomLevel}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          subject.getFormattedDuration()[0].toUpperCase() +
              subject.getFormattedDuration().substring(1),
        ),
      ],
    );
  }
}
