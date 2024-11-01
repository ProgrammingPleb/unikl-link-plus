import 'package:new_unikl_link/types/timetable/day.dart';
import 'package:new_unikl_link/utils/normalize.dart';

class TimetableData {
  List<TimetableDay> days = [];

  TimetableData(List<dynamic> rawData) {
    List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(rawData);
    TimetableDay dayData = TimetableDay(dayIndex: 9, dayName: "");
    _InternalTimetableSection currentSubject =
        _InternalTimetableSection.empty();
    int dayIndex = 9;
    bool hasSubject = true;

    void addSubjectToDay() {
      dayData.addEntry(
        branchCode: currentSubject.branchCode,
        roomCode: currentSubject.roomCode,
        dayIndex: currentSubject.dayIndex,
        subjectCode: currentSubject.subjectCode,
        subjectName: currentSubject.subjectName,
        group: currentSubject.group,
        type: currentSubject.type,
        semesterCode: currentSubject.semesterCode,
        roomDescription: currentSubject.roomDescription,
        level: currentSubject.level,
        startTime: currentSubject.startTime,
        endTime: currentSubject.endTime,
        online: currentSubject.online,
      );
    }

    try {
      for (Map<String, dynamic> slotData in data) {
        _InternalTimetableSection slot =
            _InternalTimetableSection.fromMap(slotData);
        if (dayIndex != slot.dayIndex) {
          if (dayIndex != 9) {
            addSubjectToDay();
            currentSubject = _InternalTimetableSection.empty();
            days.add(dayData);
          }
          dayData =
              TimetableDay(dayIndex: slot.dayIndex, dayName: slot.dayName);
          dayIndex = slot.dayIndex;
          hasSubject = false;
        }
        if (slot.subjectCode != currentSubject.subjectCode ||
            slot.type != currentSubject.type ||
            slot.startTime != currentSubject.endTime) {
          if (currentSubject.subjectCode != "") {
            addSubjectToDay();
          }
          currentSubject = slot;
        }
        currentSubject.endTime = slot.endTime;
        hasSubject = true;
      }
    } catch (e) {
      print(e);
    }
    if (hasSubject) {
      addSubjectToDay();
      days.add(dayData);
    }
  }
}

class _InternalTimetableSection {
  final String branchCode;
  late final String roomCode;
  late final int dayIndex;
  final String subjectCode;
  final String subjectName;
  final String group;
  final String type;
  final String semesterCode;
  final String roomDescription;
  final int? level;
  final String startTime;
  String endTime;
  late final bool online;

  _InternalTimetableSection({
    required this.branchCode,
    required String roomCode,
    required String day,
    required this.subjectCode,
    required this.subjectName,
    required this.group,
    required this.type,
    required this.semesterCode,
    required this.roomDescription,
    required this.level,
    required this.startTime,
    required this.endTime,
  }) {
    if (roomCode.contains("Online")) {
      online = true;
    } else {
      online = false;
    }
    dayIndex = int.parse(day);
    this.roomCode = roomCode.replaceFirst("1-", "");
  }

  factory _InternalTimetableSection.empty() {
    return _InternalTimetableSection(
      branchCode: "00000",
      roomCode: "",
      day: "0",
      subjectCode: "",
      subjectName: "",
      group: "",
      type: "",
      semesterCode: "",
      roomDescription: "",
      level: null,
      startTime: "",
      endTime: "",
    );
  }

  factory _InternalTimetableSection.fromMap(Map<String, dynamic> slotData) {
    return _InternalTimetableSection(
      branchCode: slotData['TT_BRANCH_CODE'],
      roomCode: slotData['TT_ROOM_CODE'],
      day: slotData['TT_DAY'],
      subjectCode: slotData['TT_SUBJECT_CODE'],
      subjectName: normalizeText(slotData['SM_DESC']),
      group: slotData['TT_GROUP'],
      type: slotData['TT_TYPE'],
      semesterCode: slotData['TT_SEMESTER_CODE'],
      roomDescription: slotData['RM_ROOM_DESC'],
      level: slotData['RM_LEVEL'],
      startTime: slotData['START_TIME'],
      endTime: slotData['END_TIME'],
    );
  }

  String get dayName {
    List days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];

    return days[dayIndex - 1];
  }
}
