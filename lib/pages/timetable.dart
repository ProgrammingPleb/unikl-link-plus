import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:new_unikl_link/components/timetable_entry_no_physical.dart';
import 'package:new_unikl_link/components/timetable_entry_with_physical.dart';
import 'package:new_unikl_link/server/query.dart';
import 'package:new_unikl_link/server/urls.dart';
import 'package:new_unikl_link/types/settings/data.dart';
import 'package:new_unikl_link/types/timetable/data.dart';
import 'package:new_unikl_link/utils/get_timetable_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimetablePage extends StatefulWidget {
  final ECitieURLs eCitieURL = ECitieURLs();
  final ECitieQuery eCitieQ = ECitieQuery();
  final Future<SharedPreferences> storeFuture;
  final SettingsData settings;

  TimetablePage({super.key, required this.storeFuture, required this.settings});

  @override
  State<TimetablePage> createState() => _TimetableState();
}

class _TimetableState extends State<TimetablePage> {
  bool _semBreak = false;
  bool _finalExam = false;
  String? _bannerText;
  List<Widget> timetableList = [];
  Widget currentView = const UnloadedData();

  @override
  void initState() {
    Future<TimetableData> getData() {
      final Completer<TimetableData> c = Completer<TimetableData>();

      widget.storeFuture.then((store) {
        if (!store.containsKey("timetable")) {
          getTimetableData(store).then((TimetableData timetable) {
            _semBreak = store.getBool("semBreak")!;
            _finalExam = store.getBool("finalExam")!;
            c.complete(timetable);
          });
        } else {
          _semBreak = store.getBool("semBreak")!;
          _finalExam = store.getBool("finalExam")!;
          c.complete(TimetableData(jsonDecode(store.getString("timetable")!)));
        }
      });

      return c.future;
    }

    getData().then((data) {
      for (var day in data.days) {
        if (widget.settings.fastingTimetable && day.dayIndex == 5) {
          timetableList.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 2),
              child: Text(
                day.dayName,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
          timetableList.add(
            const Padding(
              padding: EdgeInsets.only(bottom: 15),
              child: Text(
                "There will be a break between 12:30PM and 2:30PM.\n"
                "Any subjects which are in this range will be paused "
                "at this time.",
              ),
            ),
          );
        } else {
          timetableList.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
              child: Text(
                day.dayName,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }
        for (var entry in day.entries) {
          Widget entryType;

          if (entry.online) {
            entryType = TimetableEntryNoPhysical(
              startTime: entry.startTime(widget.settings.fastingTimetable),
              endTime: entry.endTime(widget.settings.fastingTimetable),
              subjectCode: entry.subjectCode,
              subjectName: entry.subjectName,
            );
          } else {
            entryType = TimetableEntryWithPhysical(
              startTime: entry.startTime(widget.settings.fastingTimetable),
              endTime: entry.endTime(widget.settings.fastingTimetable),
              subjectCode: entry.subjectCode,
              subjectName: entry.subjectName,
              roomCode: entry.roomCode,
            );
          }
          timetableList.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: entryType,
            ),
          );
        }
      }

      if (_semBreak) {
        _bannerText = "Currently on Semester Break";
      }
      if (_finalExam) {
        _bannerText = "Currently on Final Examination Week";
      }

      setState(() {
        currentView = LoadedData(
          timetableList: timetableList,
          bannerText: _bannerText,
        );
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        currentView,
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 20),
            child: FloatingActionButton.extended(
              onPressed: () {},
              label: Text("Refresh"),
              icon: Icon(Icons.refresh),
            ),
          ),
        ),
      ],
    );
  }
}

class UnloadedData extends StatelessWidget {
  const UnloadedData({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Loading timetable..."),
    );
  }
}

class LoadedData extends StatelessWidget {
  final List<Widget> timetableList;
  final String? bannerText;

  const LoadedData({
    super.key,
    required this.timetableList,
    this.bannerText,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (bannerText != null) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Container(
                    height: 60,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.fitWidth,
                                    child: Text(
                                      bannerText!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
              ...timetableList,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "End of Week",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
