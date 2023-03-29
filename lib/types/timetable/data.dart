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
    _InternalTimetableSection currentSubject = _InternalTimetableSection(
        startSlot: 0,
        day: "0",
        roomCode: "",
        subjectCode: "",
        subjectName: "",
        group: "");
    int dayIndex = 9;
    int endSlot = 0;

    void checkSlotEntry() {
      if (currentSubject.subjectCode != "") {
        dayData.addEntry(
          subjectCode: currentSubject.subjectCode,
          subjectName: currentSubject.subjectName,
          startSlot: currentSubject.startSlot,
          endSlot: endSlot,
          online: currentSubject.online,
          roomCode: currentSubject.roomCode,
        );
      }
    }

    try {
      for (Map<String, dynamic> slotData in data) {
        _InternalTimetableSection slot =
            _InternalTimetableSection.fromMap(slotData);

        if (slot.dayIndex != dayIndex) {
          checkSlotEntry();
          if (dayIndex != 9) {
            days.add(dayData);
          }
          dayIndex = slot.dayIndex;
          currentSubject = _InternalTimetableSection(
              startSlot: 0,
              day: "0",
              roomCode: "",
              subjectCode: "",
              subjectName: "",
              group: "");
          endSlot = 0;
          dayData =
              TimetableDay(dayIndex: slot.dayIndex, dayName: slot.dayName);
        }
        if (slot.subjectCode != currentSubject.subjectCode) {
          checkSlotEntry();
          currentSubject = slot;
          endSlot = slot.startSlot;
        } else {
          endSlot = slot.startSlot;
        }
      }
      checkSlotEntry();
      days.add(dayData);
    } catch (e) {
      DebugService(storeFuture: SharedPreferences.getInstance())
          .dataError("TimetableData", jsonEncode(data));
    }
  }
}

class _InternalTimetableSection {
  final int startSlot;
  late final bool online;
  late final int dayIndex;
  late final String roomCode;
  final String subjectCode;
  final String subjectName;
  final String group;

  _InternalTimetableSection({
    required this.startSlot,
    required String day,
    required String roomCode,
    required this.subjectCode,
    required this.subjectName,
    required this.group,
  }) {
    if (roomCode.contains("Online")) {
      online = true;
    } else {
      online = false;
    }
    dayIndex = int.parse(day);
    this.roomCode = roomCode.replaceFirst("1-", "");
  }

  factory _InternalTimetableSection.fromMap(Map<String, dynamic> slotData) {
    return _InternalTimetableSection(
      startSlot: slotData['TT_SLOT'],
      day: slotData['TT_DAY'],
      roomCode: slotData['TT_ROOM_CODE'],
      subjectCode: slotData['TT_SUBJECT_CODE'],
      subjectName: normalizeText(slotData['SM_DESC']),
      group: slotData['TT_GROUP'],
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
