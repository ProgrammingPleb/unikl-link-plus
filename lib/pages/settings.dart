import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:new_unikl_link/types/settings/data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final BuildContext prevContext;
  final Future<SharedPreferences> sharedPrefs;
  final SettingsData settingsData;
  final void Function(SettingsData data) onUpdate;

  const SettingsPage({
    super.key,
    required this.prevContext,
    required this.sharedPrefs,
    required this.settingsData,
    required this.onUpdate,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool refresh = false;
  bool hasChanged = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !refresh,
      onPopInvokedWithResult: (bool didPop, _) async {
        if (didPop && hasChanged) {
          SharedPreferences store = await widget.sharedPrefs;
          store.setString("settings", widget.settingsData.toJson());
          widget.onUpdate(widget.settingsData);
        }
        return;
      },
      child: Scaffold(
        body: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverAppBar.large(
              automaticallyImplyLeading: !refresh,
              title: const Text(
                "Settings",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: [
                      /* Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: tokenRefreshHours(context),
                      ), */
                      Column(
                          children: [
                            Text(
                              "Looking for \"Data Refresh Frequency\"?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "This feature will return in a future release. "
                              "Stay tuned!",
                            ),
                          ],
                        ),
                      SizedBox(height: 30),
                      fastingTimetable(context),
                      SizedBox(height: 30),
                      enableDebug(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> enableDebug(BuildContext context) {
    if (!widget.settingsData.debugPermissible) {
      return [];
    }

    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Text(
                      "Enable Debug Tests",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    "Enables a testing page for debugging UI issues.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    "Not needed if the UI is working properly.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              thumbIcon: switchIcons,
              value: widget.settingsData.debugMode,
              onChanged: kDebugMode
                  ? null
                  : (value) {
                      setState(() {
                        widget.settingsData.debugMode = value;
                      });
                    },
            ),
          ],
        ),
      ),
    ];
  }

  Row fastingTimetable(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text(
                "Fasting Month",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              "Changes the timetable to use the",
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              "fasting month timetable instead.",
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Switch(
          thumbIcon: switchIcons,
          value: widget.settingsData.fastingTimetable,
          onChanged: (value) {
            hasChanged = true;
            setState(() {
              widget.settingsData.fastingTimetable = value;
            });
          },
        ),
      ],
    );
  }

  Column dataRefreshHours(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Text(
                  "Data Refresh Frequency",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "Determines how frequent the data in the app "
                "should update.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Slider(
          value: widget.settingsData.tokenRefreshHours.toDouble(),
          divisions: 3,
          min: 24.0,
          max: 96.0,
          label: "${widget.settingsData.tokenRefreshHours.toString()} hours",
          onChanged: (value) {
            setState(() {
              widget.settingsData.tokenRefreshHours = value.toInt();
            });
          },
        )
      ],
    );
  }

  final WidgetStateProperty<Icon?> switchIcons =
      WidgetStateProperty.resolveWith<Icon?>(
    (Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );
}
