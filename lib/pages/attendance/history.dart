import 'package:flutter/material.dart';
import 'package:new_unikl_link/components/attendance_entry.dart';
import 'package:new_unikl_link/pages/attendance/self_attendance.dart';
import 'package:new_unikl_link/types/attendance/data.dart';
import 'package:new_unikl_link/types/attendance/subject.dart';
import 'package:new_unikl_link/types/info/student_profile.dart';
import 'package:new_unikl_link/utils/get_attendance_data.dart';
import 'package:new_unikl_link/utils/normalize.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _dataLoaded = false;
  bool refreshing = true;

  @override
  void initState() {
    initData();
    super.initState();
  }

  Future<void> initData({bool refresh = false}) async {
    setState(() {
      refreshing = true;
    });
    AttendanceData attendanceData =
        await getAttendanceData(sharedPrefs: widget.sharedPrefs);
    int pos = 0;
    if (refresh) {
      _tabs = [];
      _tabViews = [];
    }
    for (String subject in attendanceData.subjectNames) {
      _tabs.add(normalizeText(subject));
      _tabViews.add(SubjectTab(
        subject: attendanceData.subjectData[pos],
        subjectName: subject,
      ));
      pos++;
    }
    setState(() {
      if (!refresh) {
        _tabController = TabController(length: _tabs.length, vsync: this);
      }
      _dataLoaded = true;
      refreshing = false;
    });
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton.extended(
                    onPressed: () async {
                      if (!refreshing) {
                        initData(refresh: true);
                      }
                    },
                    heroTag: "RefreshAtt",
                    label: Text("Refresh"),
                    icon: getRefreshIcon(refreshing),
                  ),
                  SizedBox(height: 8),
                  FloatingActionButton.extended(
                    onPressed: () async {
                      bool? result = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (context) => SelfAttendancePage(
                            studentData: widget.studentData,
                            storeFuture: widget.sharedPrefs,
                          ),
                        ),
                      );
                      if (result != null && result && !refreshing) {
                        initData(refresh: true);
                      }
                    },
                    heroTag: "SelfAtt",
                    label: Text("Self Attendance"),
                    icon: Icon(Icons.qr_code),
                  ),
                ],
              )),
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

  final AttendanceSubject subject;
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
                    date: subject.entries[index].date,
                    classType: subject.entries[index].classType,
                    attendStatus: subject.entries[index].attendStatus,
                  ),
                );
              } else {
                return AttendanceEntry(
                  date: subject.entries[index].date,
                  classType: subject.entries[index].classType,
                  attendStatus: subject.entries[index].attendStatus,
                );
              }
            }, childCount: subject.entries.length),
          ),
        )
      ],
    );
  }
}

Widget getRefreshIcon(bool refresh) {
  if (refresh) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          value: null,
          strokeWidth: 3.0,
        ),
      ),
    );
  }
  return Icon(Icons.refresh);
}
