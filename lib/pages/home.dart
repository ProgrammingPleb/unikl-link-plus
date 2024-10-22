import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:new_unikl_link/components/info_entry.dart';
import 'package:new_unikl_link/pages/login.dart';
import 'package:new_unikl_link/types/info/student_profile.dart';
import 'package:new_unikl_link/types/settings/data.dart';
import 'package:new_unikl_link/types/subject.dart';
import 'package:new_unikl_link/utils/get_next_or_current_subject.dart';
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
  Subject nextSubject = Subject.empty();
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
    Subject nextSubject =
        await getNextOrCurrentSubject(widget.sharedPrefs, settingsData);
    setState(() {
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
              storeFuture: widget.sharedPrefs,
              relogin: true,
            ),
          ),
        );
      } else {
        data = await Navigator.push(
          context,
          MaterialPageRoute<StudentData>(
            builder: (context) => LoginPage(
              storeFuture: widget.sharedPrefs,
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
          name,
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
        InfoEntry(
          icon: Icon(
            Icons.update,
            size: 32,
          ),
          label: nextSubject.isOngoing() ? "Current Class" : "Next Class",
          data: [
            Text(
              nextSubject.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Text(
                  nextSubject.online ? "Online Class" : "Location: ",
                ),
                Text(
                  nextSubject.online
                      ? ""
                      : "${nextSubject.roomCode}, "
                          "level ${nextSubject.roomLevel}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              nextSubject.getFormattedDuration()[0].toUpperCase() +
                  nextSubject.getFormattedDuration().substring(1),
            ),
          ],
        ),
      ],
    );
  }
}
