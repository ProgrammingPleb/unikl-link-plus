import 'dart:convert';

class TimetableDayEntry {
  final String subjectCode;
  final String subjectName;
  final String startTime;
  final String endTime;
  final bool online;
  final String roomCode;

  TimetableDayEntry({
    required this.subjectCode,
    required this.subjectName,
    required this.startTime,
    required this.endTime,
    required this.online,
    required this.roomCode,
  });

  @override
  String toString() {
    return jsonEncode({
      "subjectCode": subjectCode,
      "subjectName": subjectName,
      "startTime": startTime,
      "endTime": endTime,
      "online": online,
      "roomCode": roomCode,
    });
  }
}
