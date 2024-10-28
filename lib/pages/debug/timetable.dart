import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:new_unikl_link/types/timetable/data.dart';
import 'package:new_unikl_link/types/timetable/day.dart';
import 'package:new_unikl_link/types/timetable/entry.dart';
import 'package:new_unikl_link/utils/get_timetable_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimetableDebugInfo extends StatefulWidget {
  final Future<SharedPreferences> sharedPrefs;

  const TimetableDebugInfo({
    super.key,
    required this.sharedPrefs,
  });

  @override
  State<StatefulWidget> createState() => _TimetableDebugState();
}

class _TimetableDebugState extends State<TimetableDebugInfo>
    with AutomaticKeepAliveClientMixin<TimetableDebugInfo> {
  List<Widget> entries = [Text("Loading Timetable Data")];
  bool loaded = false;

  void loadPageData() async {
    SharedPreferences store = await widget.sharedPrefs;
    List<Widget> tempEntries = [];
    late TimetableData data;

    if (store.containsKey("timetable")) {
      data = TimetableData(jsonDecode(store.getString("timetable")!));
    } else {
      data = await getTimetableData(widget.sharedPrefs);
    }

    for (TimetableDay day in data.days) {
      for (TimetableDayEntry entry in day.entries) {
        if (tempEntries.isNotEmpty) {
          tempEntries.add(SizedBox(height: 28));
        }
        tempEntries.add(Text(entry.toString()));
      }
    }

    setState(() {
      entries = tempEntries;
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    loadPageData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: entries,
        ),
      ),
    );
  }
}
