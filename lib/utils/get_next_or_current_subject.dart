import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:new_unikl_link/types/subject.dart';
import 'package:new_unikl_link/types/timetable/data.dart';
import 'package:new_unikl_link/types/timetable/day.dart';
import 'package:new_unikl_link/types/timetable/entry.dart';
import 'package:new_unikl_link/utils/get_timetable_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Subject> getNextOrCurrentSubject(Future<SharedPreferences> storeFuture) {
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
            startTime: normalizeTime(entry.startTime, checkedTime),
            endTime: normalizeTime(entry.endTime, checkedTime),
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
        startTime: normalizeTime(firstSubjectOfWeek.startTime, checkedTime),
        endTime: normalizeTime(firstSubjectOfWeek.endTime, checkedTime),
        followingWeek: true,
      );
      c.complete(currentSubject);
    }
  });

  return c.future;
}

DateTime normalizeTime(String timeString, DateTime checkedTime) {
  DateFormat subjectTimeFormat = DateFormat("hh:mma");

  DateTime time = subjectTimeFormat.parse(timeString);
  return DateTime(
    checkedTime.year,
    checkedTime.month,
    checkedTime.day,
    time.hour,
    time.minute,
  );
}
