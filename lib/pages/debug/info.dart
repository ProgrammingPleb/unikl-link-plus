import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:new_unikl_link/server/query.dart';
import 'package:new_unikl_link/server/urls.dart';
import 'package:new_unikl_link/types/info/student_profile.dart';
import 'package:new_unikl_link/types/info/student_semester.dart';
import 'package:new_unikl_link/utils/normalize.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DebugInfoPage extends StatefulWidget {
  final Future<SharedPreferences> storeFuture;
  final StudentData studentData;

  const DebugInfoPage({
    super.key,
    required this.storeFuture,
    required this.studentData,
  });

  @override
  State<DebugInfoPage> createState() => _DebugInfoPageState();
}

class _DebugInfoPageState extends State<DebugInfoPage> {
  final ECitieURLs eCitieURLs = ECitieURLs();
  final ECitieQuery eCitieQuery = ECitieQuery();
  final DateFormat dateDisplay = DateFormat("d MMMM yyyy, h:mma");
  late StudentSemesterData semesterData;
  List<Widget> studentColumnList = [];
  List<Widget> semesterColumnList = [];

  @override
  void initState() {
    studentColumnList.add(studentDataColumn());
    semesterColumn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar.large(
              title: const Text(
                "Debug Info",
                style: TextStyle(fontWeight: FontWeight.bold),
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
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...studentColumnList,
                          ...semesterColumnList,
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget studentDataColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            "Student Profile",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Text(
            "ID: ${widget.studentData.id}\n"
            "IC Number: ${widget.studentData.icNumber}\n"
            "Name: ${normalizeName(widget.studentData.name)}\n"
            "Gender: ${normalizeText(widget.studentData.gender)}\n"
            "University Email: ${widget.studentData.uniEmail}\n"
            "Personal Email: ${widget.studentData.selfEmail}\n"
            "Semester Set: ${widget.studentData.semesterSet}\n"
            "Handphone Number: ${widget.studentData.handphoneNum}\n"
            "Home Address: ${normalizeText(widget.studentData.address)}\n"
            "Postcode: ${widget.studentData.postcode}\n"
            "City: ${normalizeText(widget.studentData.city)}\n"
            "Current Semester: ${widget.studentData.currentSemester}\n"
            "Program: ${widget.studentData.programFull}\n"
            "Program Code: ${widget.studentData.programShort}\n"
            "Institute: ${widget.studentData.institute}",
          ),
        ),
      ],
    );
  }

  void semesterColumn() async {
    semesterColumnList.add(
      const Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: Column(
          children: [
            Text(
              "Semester Details",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    int semesterIndex = 1;
    SharedPreferences store = await widget.storeFuture;
    Response resp = await http.get(Uri.parse(eCitieURLs.serverQuery(
        store.getString("eCitieToken")!,
        eCitieQuery.semesterData
            .replaceAll("|STUDENTID|", widget.studentData.id))));
    semesterData = StudentSemesterData(jsonDecode(resp.body));
    for (StudentSemester semester in semesterData.semesters.reversed) {
      semesterColumnList.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Semester $semesterIndex",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Code: ${semester.code}\n"
                "Name: ${semester.name}\n"
                "Set: ${semester.set}\n"
                "Type: ${normalizeText(semester.type)}\n"
                "Year: ${semester.year}\n"
                "GPA: ${semester.gpa}\n"
                "CGPA: ${semester.cgpa}\n"
                "GPA Class: ${semester.gpaClass}\n"
                "CGPA Class: ${semester.cgpaClass}\n"
                "Total Hours: ${semester.totalHours}\n"
                "Total Subjects: ${semester.totalSubjects}\n"
                "Dean's List: ${semester.deanList}\n"
                "Start Time: ${dateDisplay.format(semester.startTime)}\n"
                "End Time: ${dateDisplay.format(semester.endTime)}",
              ),
            ],
          ),
        ),
      );
      semesterIndex++;
    }
    setState(() {});
  }
}
