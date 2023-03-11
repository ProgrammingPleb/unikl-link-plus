import 'package:flutter/material.dart';
import 'package:new_unikl_link/types/settings/data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final Future<SharedPreferences> storeFuture;
  final SettingsData settingsData;

  const SettingsPage({
    Key? key,
    required this.storeFuture,
    required this.settingsData,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar.large(
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
                      child: atAGlance(context),
                    ),
                    resetCache(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row resetCache(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text(
                "Reset Cache",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              "Resets any cached data the app has.",
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              "Only do this if there is any outdated data.",
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const FilledButton.tonal(
          onPressed: null,
          child: Text("Reset"),
        ),
      ],
    );
  }

  Row atAGlance(BuildContext context) {
    final MaterialStateProperty<Icon?> thumbIcon =
        MaterialStateProperty.resolveWith<Icon?>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return const Icon(Icons.check);
        }
        return const Icon(Icons.close);
      },
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text(
                "Show \"At A Glance\"",
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
          thumbIcon: thumbIcon,
          value: widget.settingsData.atAGlanceEnabled,
          onChanged: (value) {
            setState(() {
              widget.settingsData.atAGlanceEnabled = value;
            });
          },
        ),
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
                  "App Testing Branch",
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
            setState(() {
              widget.settingsData.appBranch = value.first;
            });
          },
        ),
      ],
    );
  }
}
