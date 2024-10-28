import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_unikl_link/pages/debug/semester.dart';
import 'package:new_unikl_link/pages/debug/store.dart';
import 'package:new_unikl_link/pages/debug/student.dart';
import 'package:new_unikl_link/pages/debug/timetable.dart';
import 'package:new_unikl_link/server/query.dart';
import 'package:new_unikl_link/server/urls.dart';
import 'package:new_unikl_link/types/info/student_profile.dart';
import 'package:new_unikl_link/types/info/student_semester.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DebugInfoPage extends StatefulWidget {
  final Future<SharedPreferences> sharedPrefs;
  final StudentData studentData;

  const DebugInfoPage({
    super.key,
    required this.sharedPrefs,
    required this.studentData,
  });

  @override
  State<DebugInfoPage> createState() => _DebugInfoPageState();
}

class _DebugInfoPageState extends State<DebugInfoPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final ECitieURLs eCitieURLs = ECitieURLs();
  final ECitieQuery eCitieQuery = ECitieQuery();
  final DateFormat dateDisplay = DateFormat("d MMMM yyyy, h:mma");
  final List<String> debugItems = ["Student", "Semester", "Timetable", "Cache"];
  late StudentSemesterData semesterData;
  int selectedDebugItem = 0;

  @override
  void initState() {
    tabController = TabController(length: debugItems.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar.medium(
              title: const Text(
                "Debug Info",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              bottom: TabBar(
                controller: tabController,
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                tabs: debugItems
                    .map((item) => Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          child: Text(item),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
        body: SafeArea(
          top: false,
          bottom: false,
          child: Builder(
            builder: (context) {
              return CustomScrollView(
                slivers: [
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                  ),
                  SliverFillRemaining(
                      child: TabBarView(
                    controller: tabController,
                    children: [
                      StudentDataDebugInfo(studentData: widget.studentData),
                      SemesterDebugInfo(
                        sharedPrefs: widget.sharedPrefs,
                        studentData: widget.studentData,
                      ),
                      TimetableDebugInfo(
                        sharedPrefs: widget.sharedPrefs,
                      ),
                      StoreDebugInfo(sharedPrefs: widget.sharedPrefs)
                    ],
                  )),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
