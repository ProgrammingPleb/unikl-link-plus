import 'package:intl/intl.dart';

class AttendanceEntryData {
  final DateTime date;
  final String classType;
  final String attendStatus;

  AttendanceEntryData({
    required this.date,
    required this.classType,
    required this.attendStatus,
  });
}

class ECitieAttendanceEntryData {
  final String subjectCode;
  final String group;
  final String type;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  ECitieAttendanceEntryData({
    this.subjectCode = "",
    this.group = "",
    this.type = "",
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    this.status = "",
  })  : date = date ?? DateTime(1970),
        startTime = startTime ?? DateTime(1970),
        endTime = endTime ?? DateTime(1970);

  factory ECitieAttendanceEntryData.fromJson(Map<String, dynamic> data) {
    final DateFormat dateFormat = DateFormat("MMM d, yyyy, hh:mm:ss a");
    final DateFormat timeFormat = DateFormat("hh:mm a");

    DateTime date = dateFormat.parse(data["SAM_DATE"]);
    DateTime startTime = timeFormat.parse(data["START_TIME"]);
    DateTime endTime = timeFormat.parse(data["END_TIME"]);
    DateTime startDate = DateTime(
        date.year, date.month, date.day, startTime.hour, startTime.minute);
    DateTime endDate =
        DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);

    return ECitieAttendanceEntryData(
      subjectCode: data["SR_SUBJECT_CODE"],
      group: data["SAM_GROUP"],
      type: data["SAM_TYPE"],
      date: date,
      startTime: startDate,
      endTime: endDate,
      status: data["SAD_ATTEND_STS"] ?? "",
    );
  }
}
