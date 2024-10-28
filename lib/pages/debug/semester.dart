import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_unikl_link/server/query.dart';
import 'package:new_unikl_link/server/urls.dart';
import 'package:new_unikl_link/types/info/student_profile.dart';
import 'package:new_unikl_link/types/info/student_semester.dart';
import 'package:new_unikl_link/utils/normalize.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SemesterDebugInfo extends StatefulWidget {
  final Future<SharedPreferences> sharedPrefs;
  final StudentData studentData;

  const SemesterDebugInfo({
    super.key,
    required this.sharedPrefs,
    required this.studentData,
  });

  @override
  State<StatefulWidget> createState() => _SemesterDebugState();
}

class _SemesterDebugState extends State<SemesterDebugInfo>
    with AutomaticKeepAliveClientMixin<SemesterDebugInfo> {
  final DateFormat dateDisplay = DateFormat("d MMMM yyyy, h:mma");
  final ECitieURLs eCitieURLs = ECitieURLs();
  final ECitieQuery eCitieQuery = ECitieQuery();
  List<Widget> semesterColumnList = [];
  late StudentSemesterData semesterData;

  void semesterColumn() async {
    int semesterIndex = 1;
    SharedPreferences store = await widget.sharedPrefs;
    http.Response resp = await eCitieURLs.sendQuery(
        widget.sharedPrefs,
        eCitieQuery.buildQuery(
            store.getString("eCitieToken")!,
            eCitieQuery.semesterData
                .replaceAll("|STUDENTID|", widget.studentData.id)));
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

  @override
  void initState() {
    semesterColumn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: semesterColumnList.isNotEmpty
            ? semesterColumnList
            : [
                Center(
                  child: Text("Loading Semester Data"),
                )
              ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
