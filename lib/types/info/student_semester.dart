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
  late final DateTime startTime;
  late final DateTime endTime;
  double? _gpa;
  double? _cgpa;

  StudentSemester({
    required this.code,
    required this.name,
    required this.set,
    required String startTime,
    required String endTime,
    gpa,
    cgpa,
  }) {
    DateFormat dateFormat = DateFormat("MMM d, yyyy h:mm:ss a");
    try {
      _gpa = double.parse(gpa.toString());
      _cgpa = double.parse(cgpa.toString());
    } catch (ex, stackTrace) {
      Sentry.captureException(ex, stackTrace: stackTrace);
    }
    this.startTime = dateFormat.parse(startTime);
    this.endTime = dateFormat.parse(endTime);
  }

  double? get gpa {
    return _gpa;
  }

  double? get cgpa {
    return _cgpa;
  }
}
