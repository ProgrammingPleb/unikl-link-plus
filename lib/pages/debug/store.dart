import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreDebugInfo extends StatefulWidget {
  final Future<SharedPreferences> sharedPrefs;

  const StoreDebugInfo({
    super.key,
    required this.sharedPrefs,
  });

  @override
  State<StatefulWidget> createState() => _TimetableDebugState();
}

class _TimetableDebugState extends State<StoreDebugInfo>
    with AutomaticKeepAliveClientMixin<StoreDebugInfo> {
  bool loaded = false;
  List<Widget> keys = [];

  void loadPageData() async {
    SharedPreferences store = await widget.sharedPrefs;
    for (String key in store.getKeys()) {
      if (keys.isNotEmpty) {
        keys.add(SizedBox(height: 28));
      }
      Object data = store.get(key)!;
      keys.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  key,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: data.toString()));
                  },
                  child: Icon(Symbols.content_copy),
                ),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Text(data.toString()),
          ],
        ),
      );
    }
    setState(() {
      loaded = true;
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
          children: loaded
              ? keys
              : [
                  Center(
                    child: Text("Loading Timetable Data"),
                  ),
                ],
        ),
      ),
    );
  }
}
