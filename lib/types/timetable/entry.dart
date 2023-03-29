import 'dart:convert';

class TimetableDayEntry {
  final int dayIndex;
  final String subjectCode;
  final String subjectName;
  final int startSlot;
  final int endSlot;
  //final String startTime;
  //final String endTime;
  final bool online;
  final String roomCode;
  final List<String> _normalSlots = ["8:30AM", "9:30AM", "10:30AM", "11:30AM", "12:30PM", "1:30PM", "2:30PM",
                                     "3:30PM", "4:30PM", "5:30PM", "6:30PM", "7:30PM", "8:30PM", "9:30PM"];
  final List<String> _fastingSlotsNonFriday = ["8.30AM", "9:20AM", "10:10AM", "11:00AM", "11:50AM", "12:40PM", "1:30PM",
                                               "2:20PM", "3:10PM", "4:00PM", "4:50PM", "5:30PM", "6:20PM", "7:10PM"];
  final List<String> _fastingSlotsFriday = ["8:30AM", "9:20AM", "10:10AM", "11:00AM", "11:50AM", "11:50AM", "11:50AM",
                                            "2:30PM", "3:20PM", "4:10PM", "5:00PM", "5:50PM", "6:40PM", "7:30PM"];

  TimetableDayEntry({
    required this.dayIndex,
    required this.subjectCode,
    required this.subjectName,
    required this.startSlot,
    required this.endSlot,
    required this.online,
    required this.roomCode,
  });

  @override
  String toString() {
    return jsonEncode({
      "subjectCode": subjectCode,
      "subjectName": subjectName,
      "startSlot": startSlot,
      "endSlot": endSlot,
      "online": online,
      "roomCode": roomCode,
    });
  }

  String startTime(bool fasting) {
    List<String> slots = _normalSlots;
    if (fasting) {
      if (dayIndex == 5) {
        slots = _fastingSlotsFriday;
      } else {
        slots = _fastingSlotsNonFriday;
      }
    }

    return slots[startSlot - 1];
  }

  String endTime(bool fasting) {
    List<String> slots = _normalSlots;
    if (fasting) {
      if (dayIndex == 5) {
        slots = _fastingSlotsFriday;
      } else {
        slots = _fastingSlotsNonFriday;
      }
    }

    return slots[endSlot];
  }
}
