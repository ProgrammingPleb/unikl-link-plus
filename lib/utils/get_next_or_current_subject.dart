import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:new_unikl_link/types/settings/data.dart';
import 'package:new_unikl_link/types/subject.dart';
import 'package:new_unikl_link/types/timetable/data.dart';
import 'package:new_unikl_link/types/timetable/day.dart';
import 'package:new_unikl_link/types/timetable/entry.dart';
import 'package:new_unikl_link/utils/get_timetable_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

final List<String> days = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday",
];

Future<Subject> getNextOrCurrentSubject({
  required Future<SharedPreferences> sharedPrefs,
  required SettingsData settings,
  bool nextOnly = false,
}) async {
  SharedPreferences store = await sharedPrefs;
  TimetableData timetable;
  int dayIndex = 1;

  if (store.containsKey("timetable")) {
    timetable = TimetableData(jsonDecode(store.getString("timetable")!));
  } else {
    timetable = await getTimetableData(sharedPrefs);
  }

  DateTime checkedTime = DateTime.now();
  String currentDay = DateFormat.EEEE().format(checkedTime);

  for (String day in days) {
    if (day == currentDay) {
      break;
    }
    dayIndex += 1;
  }

  for (TimetableDay dayData in timetable.days) {
    if (dayData.dayName == currentDay) {
      for (TimetableDayEntry entry in dayData.entries) {
        Subject currentSubject = Subject(
          name: entry.subjectName,
          code: entry.subjectCode,
          roomCode: entry.roomCode,
          online: entry.online,
          startTime: entry.getStartTimeObject(settings.fastingTimetable),
          endTime: entry.getEndTimeObject(settings.fastingTimetable),
        );
        if ((!nextOnly && currentSubject.isOngoing()) ||
            !currentSubject.hasStarted()) {
          return currentSubject;
        }
      }
    } else if (dayData.dayIndex > dayIndex) {
      TimetableDayEntry firstSubjectOfDay = dayData.entries[0];
      Subject nextSubject = Subject(
        name: firstSubjectOfDay.subjectName,
        code: firstSubjectOfDay.subjectCode,
        roomCode: firstSubjectOfDay.roomCode,
        online: firstSubjectOfDay.online,
        startTime:
            firstSubjectOfDay.getStartTimeObject(settings.fastingTimetable),
        endTime: firstSubjectOfDay.getEndTimeObject(settings.fastingTimetable),
        followingDay: dayData.dayIndex - dayIndex,
      );
      return nextSubject;
    }
  }
  TimetableDayEntry firstSubjectOfWeek = timetable.days[0].entries[0];
  Subject currentSubject = Subject(
    name: firstSubjectOfWeek.subjectName,
    code: firstSubjectOfWeek.subjectCode,
    roomCode: firstSubjectOfWeek.roomCode,
    online: firstSubjectOfWeek.online,
    startTime: firstSubjectOfWeek.getStartTimeObject(settings.fastingTimetable),
    endTime: firstSubjectOfWeek.getEndTimeObject(settings.fastingTimetable),
    followingWeek: true,
  );
  return currentSubject;
}
