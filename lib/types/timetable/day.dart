import 'package:new_unikl_link/types/timetable/entry.dart';

class TimetableDay {
  late final int dayIndex;
  late final String dayName;
  List<TimetableDayEntry> entries = [];

  TimetableDay({required this.dayIndex, required this.dayName});

  void addEntry({
    required String subjectCode,
    required String subjectName,
    required String startTime,
    required String endTime,
    required bool online,
    required String roomCode,
  }) {
    entries.add(TimetableDayEntry(
      dayIndex: dayIndex,
      subjectCode: subjectCode,
      subjectName: subjectName,
      startTime: startTime,
      endTime: endTime,
      online: online,
      roomCode: roomCode,
    ));
  }
}
