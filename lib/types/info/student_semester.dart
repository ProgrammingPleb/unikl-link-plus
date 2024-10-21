import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class StudentSemesterData {
  List<StudentSemester> semesters = [];

  StudentSemesterData(List<dynamic> rawData) {
    List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(rawData);

    for (var semester in data) {
      semesters.add(StudentSemester(
        code: semester['SM_SEMESTER_CODE'],
        name: semester['SM_SEMESTER_DESC'],
        set: semester['SM_SEMESTER_SET'],
        type: semester['SM_TYPE'],
        year: semester['SM_SESSION'],
        gpaClass: semester['RM_GPA_CLASS'],
        cgpaClass: semester['RM_CGPA_CLASS'],
        totalHours: semester['TOTAL_HR'],
        totalSubjects: semester['TOTAL_SUBJECT'],
        deanList: semester['RM_DEAN_LIST'],
        startTime: semester['SM_START'],
        endTime: semester['SM_END'],
        gpa: semester['RM_GPA'],
        cgpa: semester['RM_CGPA'],
      ));
    }
  }

  StudentSemester get latest => semesters[0];
}

class StudentSemester {
  final String code;
  final String name;
  final String set;
  final String type;
  final String year;
  late final String gpaClass;
  late final String cgpaClass;
  late final String deanList;
  final int totalHours;
  final int totalSubjects;
  late final DateTime startTime;
  late final DateTime endTime;
  double? _gpa;
  double? _cgpa;

  StudentSemester({
    required this.code,
    required this.name,
    required this.set,
    required this.type,
    required this.year,
    required String? gpaClass,
    required String? cgpaClass,
    required this.totalHours,
    required this.totalSubjects,
    required String? deanList,
    required String startTime,
    required String endTime,
    gpa,
    cgpa,
  }) {
    DateFormat dateFormat = DateFormat("MMM d, yyyy, h:mm:ss a");
    try {
      if (gpa != null) {
        _gpa = double.parse(gpa.toString());
      }
      if (cgpa != null) {
        _cgpa = double.parse(cgpa.toString());
      }
    } catch (ex, stackTrace) {
      if (!kDebugMode) {
        Sentry.captureException(ex, stackTrace: stackTrace);
      } else {
        print(ex);
      }
    }
    this.startTime = dateFormat.parse(startTime);
    this.endTime = dateFormat.parse(endTime);
    this.gpaClass = gpaClass ?? "N/A";
    this.cgpaClass = cgpaClass ?? "N/A";
    this.deanList = deanList ?? "N/A";
  }

  double? get gpa {
    return _gpa;
  }

  double? get cgpa {
    return _cgpa;
  }
}
