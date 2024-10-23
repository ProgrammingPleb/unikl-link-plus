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

Future<TimetableData> getTimetableData(SharedPreferences store) {
  Completer<TimetableData> c = Completer<TimetableData>();
  ECitieURLs eCitieURL = ECitieURLs();
  ECitieQuery eCitieQ = ECitieQuery();
  SharedPreferences store = await sharedPrefs;

  StudentData studentData =
      StudentData.fromJson(jsonDecode(store.getString("profile")!));
  http
      .get(Uri.parse(eCitieURL.serverQuery(
          store.getString("eCitieToken")!,
          eCitieQ.semesterData
              .replaceAll("|STUDENTID|", store.getString("personID")!))))
      .then((resp) {
    StudentSemesterData semesterData =
        StudentSemesterData(jsonDecode(resp.body));
    http
        .get(Uri.parse(eCitieURL.serverQuery(
            store.getString("eCitieToken")!,
            eCitieQ.currentWeek
                .replaceFirst("|SEMCODE|", semesterData.latest.code)
                .replaceAll("|SEMSET|", semesterData.latest.set))))
        .then((resp) {
      Map<String, dynamic> weekData =
          Map<String, dynamic>.from(jsonDecode(resp.body)[0]);
      SemesterWeek currentWeek = SemesterWeek(weekData);
      http
          .get(Uri.parse(eCitieURL.serverQuery(
              store.getString("eCitieToken")!,
              eCitieQ.timetable
                  .replaceFirst("|STUDENTID|", store.getString("personID")!)
                  .replaceFirst("|SEMCODE|", semesterData.latest.code)
                  .replaceFirst("|BRANCHCODE|", studentData.branchCode)
                  .replaceFirst(
                      "|WEEK|",
                      currentWeek.number
                          .toString()
                          .replaceAll("|SEMSET|", semesterData.latest.set)))))
          .then((resp) {
        TimetableData timetableData = TimetableData(jsonDecode(resp.body));
        if (timetableData.days[0].entries.isEmpty) {
          http
              .get(Uri.parse(eCitieURL.serverQuery(
                  store.getString("eCitieToken")!,
                  eCitieQ.timetable
                      .replaceFirst("|STUDENTID|", store.getString("personID")!)
                      .replaceFirst("|SEMCODE|", semesterData.latest.code)
                      .replaceFirst("|BRANCHCODE|", studentData.branchCode)
                      .replaceFirst("|WEEK|", "1"))))
              .then(
            (resp) {
              timetableData = TimetableData(jsonDecode(resp.body));
              store.setString("timetable", resp.body);
              store.setBool("semBreak", currentWeek.type == "Semester Break");
              store.setBool("finalExam", currentWeek.type == "Exam");
              c.complete(timetableData);
            },
          );
        } else {
          store.setString("timetable", resp.body);
          store.setBool("semBreak", currentWeek.type == "Semester Break");
          store.setBool("finalExam", currentWeek.type == "Exam");
          c.complete(timetableData);
        }
      });
    });
  });

  return c.future;
}
