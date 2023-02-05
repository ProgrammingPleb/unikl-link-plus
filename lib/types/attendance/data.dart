// ignore_for_file: prefer_final_fields

import 'package:intl/intl.dart';
import 'package:new_unikl_link/types/attendance/entry.dart';
import 'package:new_unikl_link/utils/normalize.dart';

class AttendanceData {
  Map<String, List<AttendanceEntryData>> _entryData = {};
  Map<String, String> _subjects = {};
  final DateFormat _dateFormat = DateFormat("MMM d, yyyy h:mm:ss a");

  AttendanceData(List<dynamic> data) {
    // TODO: Bring subject into it's own type (in info folder) file
    for (var rawSubject in data) {
      Map<String, dynamic> subject = Map<String, dynamic>.from(rawSubject);
      _entryData[subject["SM_CODE"]] = [];
      _subjects[normalizeText(subject["SM_DESC"])] = subject["SM_CODE"];
    }
  }

  void addEntries(List<dynamic> data) {
    for (var rawEntry in data) {
      Map<String, dynamic> entry = Map<String, dynamic>.from(rawEntry);
      String classType = "Lecture";
      String attendStatus = "Not Updated";
      if (entry["SAM_TYPE"] == "B") {
        classType = "Lab";
      }
      if (entry["SAM_TYPE"] == "T") {
        classType = "Tutorial";
      }
      if (entry["SAM_TYPE"] == "W") {
        classType = "Workshop";
      }
      if (entry["SAD_ATTEND_STS"] == "A") {
        attendStatus = "Attended";
      }
      if (entry["SAD_ATTEND_STS"] == "B") {
        attendStatus = "Absent";
      }
      if (entry["SAD_ATTEND_STS"] == "M") {
        attendStatus = "Medical Leave";
      }
      if (entry["SAD_ATTEND_STS"] == "L") {
        attendStatus = "On Leave";
      }
      _entryData[entry["SR_SUBJECT_CODE"]]!.add(AttendanceEntryData(
        date: _dateFormat.parse(entry["SAM_DATE"]),
        classType: classType,
        attendStatus: attendStatus,
      ));
    }
  }

  List<String> get subjects {
    return List.from(_subjects.keys);
  }

  List<List<AttendanceEntryData>> get entryData {
    List<List<AttendanceEntryData>> entryData = [];
    for (String subject in _subjects.keys) {
      entryData.add(_entryData[_subjects[subject]]!);
    }
    return entryData;
  }
}
