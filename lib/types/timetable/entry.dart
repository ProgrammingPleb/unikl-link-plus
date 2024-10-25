import 'dart:convert';

import 'package:intl/intl.dart';

final Map<String, String> _fastingSlotsMapNonFriday = {
  "08:30 AM": "08:30 AM",
  "09:30 AM": "09:20 AM",
  "10:30 AM": "10:10 AM",
  "11:30 AM": "11:00 AM",
  "12:30 PM": "11:50 AM",
  "01:30 PM": "12:40 PM",
  "02:30 PM": "01:30 PM",
  "03:30 PM": "02:20 PM",
  "04:30 PM": "03:10 PM",
  "05:30 PM": "04:00 PM",
  "06:30 PM": "04:50 PM",
  "07:30 PM": "05:30 PM",
  "08:30 PM": "06:20 PM",
  "09:30 PM": "07:10 PM",
};

final Map<String, String> _fastingSlotsMapFriday = {
  "08:30 AM": "08:30 AM",
  "09:30 AM": "09:20 AM",
  "10:30 AM": "10:10 AM",
  "11:30 AM": "11:00 AM",
  "12:30 PM": "11:50 AM",
  "01:30 PM": "11:50 AM",
  "02:30 PM": "11:50 AM",
  "03:30 PM": "02:30 PM",
  "04:30 PM": "03:20 PM",
  "05:30 PM": "04:10 PM",
  "06:30 PM": "05:00 PM",
  "07:30 PM": "05:50 PM",
  "08:30 PM": "06:40 PM",
  "09:30 PM": "07:30 PM",
};
final DateFormat timeFormat = DateFormat("hh:mm a");

class TimetableDayEntry {
  final int dayIndex;
  final String subjectCode;
  final String subjectName;
  final String startTime;
  final String endTime;
  final bool online;
  final String roomCode;
  final String group;

  TimetableDayEntry({
    required this.dayIndex,
    required this.subjectCode,
    required this.subjectName,
    required this.startTime,
    required this.endTime,
    required this.online,
    required this.roomCode,
    required this.group,
  });

  @override
  String toString() {
    return jsonEncode({
      "dayIndex": dayIndex,
      "subjectCode": subjectCode,
      "subjectName": subjectName,
      "startTime": startTime,
      "endTime": endTime,
      "online": online,
      "roomCode": roomCode,
    });
  }

  DateTime getStartTimeObject(bool fasting) {
    DateTime currentTime = DateTime.now();
    DateTime subjectTime = timeFormat.parse(startTime);
    if (fasting) {
      if (dayIndex == 5) {
        subjectTime = timeFormat.parse(_fastingSlotsMapFriday[startTime]!);
      } else {
        subjectTime = timeFormat.parse(_fastingSlotsMapNonFriday[startTime]!);
      }
    }
    int dayIndexDiff = dayIndex - currentTime.weekday;
    if (dayIndexDiff < 0) {
      dayIndexDiff += 7;
    }
    DateTime result = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day + dayIndexDiff,
      subjectTime.hour,
      subjectTime.minute,
    );
    return result;
  }

  DateTime getEndTimeObject(bool fasting) {
    DateTime currentTime = DateTime.now();
    DateTime subjectTime = timeFormat.parse(endTime);
    if (fasting) {
      if (dayIndex == 5) {
        subjectTime = timeFormat.parse(_fastingSlotsMapFriday[endTime]!);
      } else {
        subjectTime = timeFormat.parse(_fastingSlotsMapNonFriday[endTime]!);
      }
    }
    int dayIndexDiff = dayIndex - currentTime.weekday;
    if (dayIndexDiff < 0) {
      dayIndexDiff += 7;
    }
    DateTime result = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day + dayIndexDiff,
      subjectTime.hour,
      subjectTime.minute,
    );
    return result;
  }
}
