import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_unikl_link/components/timetable_entry_no_physical.dart';
import 'package:new_unikl_link/components/timetable_entry_with_physical.dart';
import 'package:new_unikl_link/server/query.dart';
import 'package:new_unikl_link/server/urls.dart';
import 'package:new_unikl_link/types/info/semester_week.dart';
import 'package:new_unikl_link/types/info/student_profile.dart';
import 'package:new_unikl_link/types/info/student_semester.dart';
import 'package:new_unikl_link/types/timetable/data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimetablePage extends StatefulWidget {
  final ECitieURLs eCitieURL = ECitieURLs();
  final ECitieQuery eCitieQ = ECitieQuery();
  final Future<SharedPreferences> storeFuture;

  TimetablePage({Key? key, required this.storeFuture}) : super(key: key);

  @override
  State<TimetablePage> createState() => _TimetableState();
}

class _TimetableState extends State<TimetablePage> {
  bool _loading = true;
  bool _semBreak = false;
  List<Widget> timetableList = [];
  Widget currentView = const UnloadedData();

  @override
  void initState() {
    Future<TimetableData> getData() {
      final Completer<TimetableData> c = Completer<TimetableData>();

      widget.storeFuture.then((store) {
        if (!store.containsKey("timetable")) {
          StudentData studentData =
              StudentData.fromJson(jsonDecode(store.getString("profile")!));
          http
              .get(Uri.parse(widget.eCitieURL.serverQuery(
                  store.getString("eCitieToken")!,
                  widget.eCitieQ.semesterData.replaceAll(
                      "|STUDENTID|", store.getString("personID")!))))
              .then((resp) {
            StudentSemesterData semesterData =
                StudentSemesterData(jsonDecode(resp.body));
            http
                .get(Uri.parse(widget.eCitieURL.serverQuery(
                    store.getString("eCitieToken")!,
                    widget.eCitieQ.currentWeek
                        .replaceFirst("|SEMCODE|", semesterData.latest.code)
                        .replaceAll("|SEMSET|", semesterData.latest.set))))
                .then((resp) {
              Map<String, dynamic> weekData =
                  Map<String, dynamic>.from(jsonDecode(resp.body)[0]);
              SemesterWeek currentWeek = SemesterWeek(weekData);
              http
                  .get(Uri.parse(widget.eCitieURL.serverQuery(
                      store.getString("eCitieToken")!,
                      widget.eCitieQ.timetable
                          .replaceFirst(
                              "|STUDENTID|", store.getString("personID")!)
                          .replaceFirst("|SEMCODE|", semesterData.latest.code)
                          .replaceFirst("|BRANCHCODE|", studentData.branchCode)
                          .replaceFirst(
                              "|WEEK|", currentWeek.number.toString()))))
                  .then((resp) {
                store.setString("timetable", resp.body);
                store.setBool("semBreak", currentWeek.type == "Semester Break");
                _semBreak = currentWeek.type == "Semester Break";
                c.complete(TimetableData(jsonDecode(resp.body)));
              });
            });
          });
        } else {
          _semBreak = store.getBool("semBreak")!;
          c.complete(TimetableData(jsonDecode(store.getString("timetable")!)));
        }
      });

      return c.future;
    }

    getData().then((data) {
      for (var day in data.days) {
        timetableList.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
            child: Text(
              day.dayName,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        for (var entry in day.entries) {
          Widget entryType;

          if (entry.online) {
            entryType = TimetableEntryNoPhysical(
              startTime: entry.startTime,
              endTime: entry.endTime,
              subjectCode: entry.subjectCode,
              subjectName: entry.subjectName,
            );
          } else {
            entryType = TimetableEntryWithPhysical(
              startTime: entry.startTime,
              endTime: entry.endTime,
              subjectCode: entry.subjectCode,
              subjectName: entry.subjectName,
              roomCode: entry.roomCode,
            );
          }
          timetableList.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: entryType,
            ),
          );
        }
      }

      setState(() {
        _loading = false;
        currentView = LoadedData(
          timetableList: timetableList,
          semBreak: _semBreak,
        );
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar.large(
            floating: true,
            title: const Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text("Student Timetable"),
            ),
            actions: [
              if (_loading) ...[
                const Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: Center(
                    child: SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                )
              ],
            ],
          ),
        ],
        body: currentView,
      ),
    );
  }
}

class UnloadedData extends StatelessWidget {
  const UnloadedData({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Loading timetable..."),
    );
  }
}

class LoadedData extends StatelessWidget {
  final List<Widget> timetableList;
  final bool semBreak;

  const LoadedData({
    Key? key,
    required this.timetableList,
    required this.semBreak,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (semBreak) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Container(
                    height: 60,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Currently on Semester Break",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
              ...timetableList,
            ],
          ),
        ),
      ),
    );
  }
}
