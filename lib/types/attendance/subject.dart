import 'package:new_unikl_link/types/attendance/entry.dart';

class AttendanceSubject {
  final String code;
  final String name;
  List<AttendanceEntryData> entries = [];

  AttendanceSubject({
    required this.code,
    required this.name,
  });

  void addEntry(ECitieAttendanceEntryData data) {
    String classType = "Lecture";
    String attendStatus = "Not Updated";
    if (data.type == "B") {
      classType = "Lab";
    }
    if (data.type == "T") {
      classType = "Tutorial";
    }
    if (data.type == "W") {
      classType = "Workshop";
    }
    if (data.status == "A") {
      attendStatus = "Attended";
    }
    if (data.status == "B") {
      attendStatus = "Absent";
    }
    if (data.status == "M") {
      attendStatus = "Medical Leave";
    }
    if (data.status == "L") {
      attendStatus = "On Leave";
    }
    entries.add(AttendanceEntryData(
      date: data.date,
      classType: classType,
      attendStatus: attendStatus,
    ));
  }
}
