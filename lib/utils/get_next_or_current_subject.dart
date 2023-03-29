import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:new_unikl_link/types/settings/data.dart';
import 'package:new_unikl_link/types/subject.dart';
import 'package:new_unikl_link/types/timetable/data.dart';
import 'package:new_unikl_link/types/timetable/day.dart';
import 'package:new_unikl_link/types/timetable/entry.dart';
import 'package:new_unikl_link/utils/get_timetable_data.dart';
import 'package:new_unikl_link/utils/normalize.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Subject> getNextOrCurrentSubject(Future<SharedPreferences> storeFuture, SettingsData settings) {
  Completer<Subject> c = Completer<Subject>();
  TimetableData timetable;
  bool foundSubject = false;

  storeFuture.then((SharedPreferences store) async {
    if (store.containsKey("timetable")) {
      timetable = TimetableData(jsonDecode(store.getString("timetable")!));
    } else {
      timetable = await getTimetableData(store);
    }

    DateTime checkedTime = DateTime.now();
    String currentDay = DateFormat.EEEE().format(checkedTime);

    for (TimetableDay dayData in timetable.days) {
      if (dayData.dayName == currentDay) {
        for (TimetableDayEntry entry in dayData.entries) {
          Subject currentSubject = Subject(
            name: entry.subjectName,
            code: entry.subjectCode,
            roomCode: entry.roomCode,
            online: entry.online,
            startTime: normalizeTime(entry.startTime(settings.fastingTimetable), checkedTime),
            endTime: normalizeTime(entry.endTime(settings.fastingTimetable), checkedTime),
          );
          if (currentSubject.isOngoing() || !currentSubject.hasStarted()) {
            c.complete(currentSubject);
            foundSubject = true;
            break;
          }
        }
        if (!foundSubject) {
          checkedTime = checkedTime.add(const Duration(days: 1));
          currentDay = DateFormat.EEEE().format(checkedTime);
        }
      }
    }
    if (!foundSubject) {
      TimetableDayEntry firstSubjectOfWeek = timetable.days[0].entries[0];
      Subject currentSubject = Subject(
        name: firstSubjectOfWeek.subjectName,
        code: firstSubjectOfWeek.subjectCode,
        roomCode: firstSubjectOfWeek.roomCode,
        online: firstSubjectOfWeek.online,
        startTime: normalizeTime(firstSubjectOfWeek.startTime(settings.fastingTimetable), checkedTime),
        endTime: normalizeTime(firstSubjectOfWeek.endTime(settings.fastingTimetable), checkedTime),
        followingWeek: true,
      );
      c.complete(currentSubject);
    }
  });

  return c.future;
}
