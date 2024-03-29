import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:new_unikl_link/pages/login.dart';
import 'package:new_unikl_link/server/query.dart';
import 'package:new_unikl_link/server/urls.dart';
import 'package:new_unikl_link/types/info/student_profile.dart';
import 'package:new_unikl_link/types/settings/data.dart';
import 'package:new_unikl_link/types/settings/reload_data.dart';
import 'package:new_unikl_link/utils/get_timetable_data.dart';
import 'package:new_unikl_link/utils/token_tools.dart';
import 'package:new_unikl_link/utils/update/checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final BuildContext prevContext;
  final Future<SharedPreferences> storeFuture;
  final SettingsData settingsData;

  const SettingsPage({
    Key? key,
    required this.prevContext,
    required this.storeFuture,
    required this.settingsData,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool refresh = false;
  ReloadData reloadData = ReloadData();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!refresh) {
          Navigator.of(context).pop(reloadData);
        }
        return false;
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: appReleaseBranch(context),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: tokenRefreshHours(context),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: atAGlance(context),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: fastingTimetable(context),
                      ),
                      ...enableDebug(context),
                      resetCache(context),
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
                        reloadData.debugInterface = true;
                        widget.settingsData.debugMode = value;
                      });
                    },
            ),
          ],
        ),
      ),
    ];
  }

  Row resetCache(BuildContext context) {
    Widget resetElement() {
      if (refresh) {
        return const Padding(
          padding: EdgeInsets.only(right: 10),
          child: SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              strokeWidth: 3,
            ),
          ),
        );
      }
      return FilledButton.tonal(
        onPressed: () {
          setState(() {
            refresh = true;
          });

          ECitieURLs eCitieURLs = ECitieURLs();
          ECitieQuery eCitieQuery = ECitieQuery();
          checkToken(storeFuture: widget.storeFuture, resetCache: true)
              .then((status) {
            if (!status.valid) {
              if (status.needsRelogin) {
                Navigator.push(
                  context,
                  MaterialPageRoute<StudentData>(
                    builder: (context) => LoginPage(
                      eCitieURL: eCitieURLs,
                      eCitieQ: eCitieQuery,
                      storeFuture: widget.storeFuture,
                      relogin: true,
                    ),
                  ),
                ).then((data) {
                  reloadData.studentProfile = true;
                  reloadData.studentData = data;
                });
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute<StudentData>(
                    builder: (context) => LoginPage(
                      eCitieURL: eCitieURLs,
                      eCitieQ: eCitieQuery,
                      storeFuture: widget.storeFuture,
                    ),
                  ),
                ).then((data) {
                  reloadData.studentProfile = true;
                  reloadData.studentData = data;
                });
              }
            }

            widget.storeFuture.then((store) {
              getTimetableData(store).then((value) {
                setState(() {
                  refresh = false;
                });
              });
            });
          });
        },
        child: const Text("Reset"),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                refresh ? "Resetting Cache" : "Reset Cache",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              refresh
                  ? "The app will remain on this page while"
                  : "Resets any cached data the app has.",
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              refresh
                  ? "while new data is being fetched from the server."
                  : "Only do this if there is any outdated data.",
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        resetElement(),
      ],
    );
  }

  Row atAGlance(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text(
                "Show \"At a Glance\"",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              "Displays info about the next subject",
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              "on the front page.",
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Switch(
          thumbIcon: switchIcons,
          value: widget.settingsData.atAGlanceEnabled,
          onChanged: (value) {
            setState(() {
              reloadData.atAGlance = true;
              widget.settingsData.atAGlanceEnabled = value;
            });
          },
        ),
      ],
    );
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
            setState(() {
              reloadData.atAGlance = true;
              widget.settingsData.fastingTimetable = value;
            });
          },
        ),
      ],
    );
  }

  Column tokenRefreshHours(BuildContext context) {
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

  Column appReleaseBranch(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Text(
                  "App Release Branch",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "Determines which release branch the app "
                "should update to.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: "stable",
              label: SizedBox(
                width: 35,
                child: Text(
                  "Stable",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
            ButtonSegment(
              value: "dev",
              label: SizedBox(
                width: 35,
                child: Text(
                  "Dev",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
            ButtonSegment(
              value: "canary",
              label: SizedBox(
                width: 35,
                child: Text(
                  "Canary",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
          ],
          selected: {widget.settingsData.appBranch},
          onSelectionChanged: (value) {
            mainCheckUpdates(widget.prevContext, widget.settingsData);
            setState(() {
              widget.settingsData.appBranch = value.first;
            });
          },
        ),
      ],
    );
  }

  final MaterialStateProperty<Icon?> switchIcons =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );
}
