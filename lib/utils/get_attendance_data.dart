import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:new_unikl_link/server/query.dart';
import 'package:new_unikl_link/server/urls.dart';
import 'package:new_unikl_link/types/attendance/data.dart';
import 'package:new_unikl_link/types/info/student_semester.dart';
import 'package:new_unikl_link/utils/process_subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AttendanceData> getAttendanceData({
  required Future<SharedPreferences> sharedPrefs,
  bool refresh = false,
}) async {
  ECitieURLs eCitieURLs = ECitieURLs();
  ECitieQuery eCitieQuery = ECitieQuery();
  SharedPreferences store = await sharedPrefs;

  http.Response serverResp = await eCitieURLs.sendQuery(
      sharedPrefs,
      eCitieQuery.buildQuery(
          store.getString("eCitieToken")!,
          eCitieQuery.semesterData.replaceAll(
            "|STUDENTID|",
            store.getString("personID")!,
          )));
  StudentSemesterData semesterData =
      StudentSemesterData(jsonDecode(serverResp.body));
  serverResp = await eCitieURLs.sendQuery(
      sharedPrefs,
      eCitieQuery.buildQuery(
          store.getString("eCitieToken")!,
          eCitieQuery.subjects
              .replaceFirst("|SEMCODE|", semesterData.latest.code)
              .replaceFirst("|STUDENTID|", store.getString("personID")!)));
  AttendanceData attendanceData =
      AttendanceData(processSubjects(jsonDecode(serverResp.body)));
  serverResp = await eCitieURLs.sendQuery(
      sharedPrefs,
      eCitieQuery.buildQuery(
          store.getString("eCitieToken")!,
          eCitieQuery.attendanceHistory
              .replaceFirst("|SEMCODE|", semesterData.latest.code)
              .replaceFirst("|STUDENTID|", store.getString("personID")!)));
  attendanceData.addEntries(jsonDecode(serverResp.body));
  return attendanceData;
}
