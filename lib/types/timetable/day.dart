import 'package:new_unikl_link/types/timetable/entry.dart';

class TimetableDay {
  late final int dayIndex;
  late final String dayName;
  List<TimetableDayEntry> entries = [];

  TimetableDay({required this.dayIndex, required this.dayName});

  void addEntry({
    required String branchCode,
    required String roomCode,
    required int dayIndex,
    required String subjectCode,
    required String subjectName,
    required String group,
    required String type,
    required String semesterCode,
    required String roomDescription,
    required int? level,
    required String startTime,
    required String endTime,
    required bool online,
  }) {
    entries.add(TimetableDayEntry(
      branchCode: branchCode,
      roomCode: roomCode,
      dayIndex: dayIndex,
      subjectCode: subjectCode,
      subjectName: subjectName,
      group: group,
      type: type,
      semesterCode: semesterCode,
      roomDescription: roomDescription,
      level: level,
      startTime: startTime,
      endTime: endTime,
      online: online,
    ));
  }
}
