import 'dart:convert';
import 'package:new_unikl_link/types/debug.dart';
import 'package:new_unikl_link/types/timetable/day.dart';
import 'package:new_unikl_link/utils/normalize.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        subjectCode: currentSubject.subjectCode,
        subjectName: currentSubject.subjectName,
        startTime: currentSubject.startTime,
        endTime: currentSubject.endTime,
        online: currentSubject.online,
        roomCode: currentSubject.roomCode,
        group: currentSubject.group,
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
      DebugService(storeFuture: SharedPreferences.getInstance())
          .dataError("TimetableData", jsonEncode(data));
    }
    if (hasSubject) {
      addSubjectToDay();
      days.add(dayData);
    }
  }
}

class _InternalTimetableSection {
  late final bool online;
  late final int dayIndex;
  late final String roomCode;
  final String subjectCode;
  final String subjectName;
  final String group;
  final String startTime;
  String endTime;

  _InternalTimetableSection({
    required String day,
    required String roomCode,
    required this.subjectCode,
    required this.subjectName,
    required this.group,
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
      day: "0",
      roomCode: "",
      subjectCode: "",
      subjectName: "",
      group: "",
      startTime: "",
      endTime: "",
    );
  }

  factory _InternalTimetableSection.fromMap(Map<String, dynamic> slotData) {
    return _InternalTimetableSection(
      day: slotData['TT_DAY'],
      roomCode: slotData['TT_ROOM_CODE'],
      subjectCode: slotData['TT_SUBJECT_CODE'],
      subjectName: normalizeText(slotData['SM_DESC']),
      group: slotData['TT_GROUP'],
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
