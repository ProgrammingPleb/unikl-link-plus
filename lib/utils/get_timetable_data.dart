import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:new_unikl_link/server/query.dart';
import 'package:new_unikl_link/server/urls.dart';
import 'package:new_unikl_link/types/info/semester_week.dart';
import 'package:new_unikl_link/types/info/student_profile.dart';
import 'package:new_unikl_link/types/info/student_semester.dart';
import 'package:new_unikl_link/types/timetable/data.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<TimetableData> getTimetableData(
    Future<SharedPreferences> sharedPrefs) async {
  ECitieURLs eCitieURL = ECitieURLs();
  ECitieQuery eCitieQ = ECitieQuery();
  SharedPreferences store = await sharedPrefs;

  StudentData studentData =
      StudentData.fromJson(jsonDecode(store.getString("profile")!));
  http.Response resp = await eCitieURL.sendQuery(
      sharedPrefs,
      eCitieQ.buildQuery(
          store.getString("eCitieToken")!,
          eCitieQ.semesterData
              .replaceAll("|STUDENTID|", store.getString("personID")!)));
  StudentSemesterData semesterData = StudentSemesterData(jsonDecode(resp.body));
  resp = await eCitieURL.sendQuery(
      sharedPrefs,
      eCitieQ.buildQuery(
          store.getString("eCitieToken")!,
          eCitieQ.currentWeek
              .replaceFirst("|SEMCODE|", semesterData.latest.code)
              .replaceAll("|SEMSET|", semesterData.latest.set)));
  Map<String, dynamic> weekData =
      Map<String, dynamic>.from(jsonDecode(resp.body)[0]);
  SemesterWeek currentWeek = SemesterWeek(weekData);
  resp = await eCitieURL.sendQuery(
      sharedPrefs,
      eCitieQ.buildQuery(
          store.getString("eCitieToken")!,
          eCitieQ.timetable
              .replaceFirst("|STUDENTID|", store.getString("personID")!)
              .replaceFirst("|SEMCODE|", semesterData.latest.code)
              .replaceFirst("|BRANCHCODE|", studentData.branchCode)
              .replaceFirst(
                  "|WEEK|",
                  currentWeek.number
                      .toString()
                      .replaceAll("|SEMSET|", semesterData.latest.set))));
  TimetableData timetableData = TimetableData(jsonDecode(resp.body));
  if (timetableData.days[0].entries.isEmpty) {
    resp = await eCitieURL.sendQuery(
        sharedPrefs,
        eCitieQ.buildQuery(
            store.getString("eCitieToken")!,
            eCitieQ.timetable
                .replaceFirst("|STUDENTID|", store.getString("personID")!)
                .replaceFirst("|SEMCODE|", semesterData.latest.code)
                .replaceFirst("|BRANCHCODE|", studentData.branchCode)
                .replaceFirst("|WEEK|", "1")));
    timetableData = TimetableData(jsonDecode(resp.body));
    store.setString("timetable", resp.body);
    store.setBool("semBreak", currentWeek.type == "Semester Break");
    store.setBool("finalExam", currentWeek.type == "Exam");
  } else {
    store.setString("timetable", resp.body);
    store.setBool("semBreak", currentWeek.type == "Semester Break");
    store.setBool("finalExam", currentWeek.type == "Exam");
  }
  return timetableData;
}
