import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_unikl_link/pages/attendance/self_attendance.dart';
import 'package:new_unikl_link/server/query.dart';
import 'package:new_unikl_link/server/urls.dart';
import 'package:new_unikl_link/types/attendance/data.dart';
import 'package:new_unikl_link/types/info/student_profile.dart';
import 'package:new_unikl_link/types/info/student_semester.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_unikl_link/components/attendance_entry.dart';
import 'package:new_unikl_link/types/attendance/entry.dart';

class AttendanceHistoryPage extends StatefulWidget {
  final Future<SharedPreferences> sharedPrefs;
  final StudentData studentData;

  const AttendanceHistoryPage({
    super.key,
    required this.sharedPrefs,
    required this.studentData,
  });

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistory();
}

class _AttendanceHistory extends State<AttendanceHistoryPage>
    with SingleTickerProviderStateMixin {
  // ignore: prefer_final_fields
  List<String> _tabs = [];
  // ignore: prefer_final_fields
  List<Widget> _tabViews = [];
  late final TabController _tabController;
  final ECitieURLs _eCitieURLs = ECitieURLs();
  final ECitieQuery _eCitieQuery = ECitieQuery();
  bool _dataLoaded = false;

  @override
  void initState() {
    widget.sharedPrefs.then((store) {
      http
          .get(Uri.parse(_eCitieURLs.serverQuery(
              store.getString("eCitieToken")!,
              _eCitieQuery.semesterData
                  .replaceAll("|STUDENTID|", store.getString("personID")!))))
          .then((resp) {
        StudentSemesterData semesterData =
            StudentSemesterData(jsonDecode(resp.body));
        http
            .get(Uri.parse(_eCitieURLs.serverQuery(
                store.getString("eCitieToken")!,
                _eCitieQuery.subjects
                    .replaceFirst("|SEMCODE|", semesterData.latest.code)
                    .replaceFirst(
                        "|STUDENTID|", store.getString("personID")!))))
            .then((resp) {
          AttendanceData attendanceData = AttendanceData(jsonDecode(resp.body));
          http
              .get(Uri.parse(_eCitieURLs.serverQuery(
                  store.getString("eCitieToken")!,
                  _eCitieQuery.attendanceHistory
                      .replaceFirst("|SEMCODE|", semesterData.latest.code)
                      .replaceFirst(
                          "|STUDENTID|", store.getString("personID")!))))
              .then((resp) {
            attendanceData.addEntries(jsonDecode(resp.body));
            int pos = 0;
            for (String subject in attendanceData.subjects) {
              _tabs.add(subject);
              _tabViews.add(SubjectTab(
                subject: attendanceData.entryData[pos],
                subjectName: subject,
              ));
              pos++;
            }
            setState(() {
              _tabController = TabController(length: _tabs.length, vsync: this);
              _dataLoaded = true;
            });
          });
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _dataLoaded
            ? LoadedBody(
                tabController: _tabController,
                tabNames: _tabs,
                tabViews: _tabViews,
              )
            : const UnloadedBody(),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 20),
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SelfAttendancePage(
                      studentData: widget.studentData,
                      storeFuture: widget.sharedPrefs,
                    ),
                  ),
                );
              },
              label: Text("Self Attendance"),
              icon: Icon(Icons.qr_code),
            ),
          ),
        ),
      ],
    );
  }
}

class UnloadedBody extends StatelessWidget {
  const UnloadedBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Loading Attendance Data..."),
    );
  }
}

class LoadedBody extends StatelessWidget {
  final TabController tabController;
  final List<String> tabNames;
  final List<Widget> tabViews;

  const LoadedBody({
    super.key,
    required this.tabController,
    required this.tabNames,
    required this.tabViews,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: tabController,
          tabAlignment: TabAlignment.start,
          isScrollable: true,
          tabs: List<Widget>.from(
            tabNames.map(
              (name) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(name),
              ),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(controller: tabController, children: [
            ...tabViews.map((tabView) {
              return SafeArea(
                top: false,
                bottom: false,
                child: Builder(builder: (context) {
                  return tabView;
                }),
              );
            })
          ]),
        ),
      ],
    );
  }
}

class SubjectTab extends StatelessWidget {
  const SubjectTab({
    super.key,
    required this.subject,
    required this.subjectName,
  });

  final List<AttendanceEntryData> subject;
  final String subjectName;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index != 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: AttendanceEntry(
                    date: subject[index].date,
                    classType: subject[index].classType,
                    attendStatus: subject[index].attendStatus,
                  ),
                );
              } else {
                return AttendanceEntry(
                  date: subject[index].date,
                  classType: subject[index].classType,
                  attendStatus: subject[index].attendStatus,
                );
              }
            }, childCount: subject.length),
          ),
        )
      ],
    );
  }
}
