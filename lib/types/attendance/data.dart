// ignore_for_file: prefer_final_fields

import 'package:new_unikl_link/types/attendance/entry.dart';
import 'package:new_unikl_link/types/attendance/subject.dart';
import 'package:new_unikl_link/types/subject.dart';

class AttendanceData {
  Map<String, AttendanceSubject> _entryData = {};

  AttendanceData(List<SemesterSubject> subjects) {
    for (SemesterSubject subject in subjects) {
      _entryData[subject.code] =
          AttendanceSubject(code: subject.code, name: subject.name);
    }
  }

  void addEntries(List<dynamic> data) {
    for (dynamic entry in data) {
      ECitieAttendanceEntryData eCitieEntryData =
          ECitieAttendanceEntryData.fromJson(entry);
      if (_entryData.keys.contains(eCitieEntryData.subjectCode)) {
        _entryData[eCitieEntryData.subjectCode]!.addEntry(eCitieEntryData);
      }
    }
  }

  List<String> get subjectNames {
    List<String> names = [];
    for (AttendanceSubject subject in _entryData.values) {
      names.add(subject.name);
    }

    return names;
  }

  List<AttendanceSubject> get subjectData {
    return List.from(_entryData.values);
  }
}
