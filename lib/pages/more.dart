import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:new_unikl_link/components/menu_entry.dart';
import 'package:new_unikl_link/pages/debug/page.dart';
import 'package:new_unikl_link/pages/login.dart';
import 'package:new_unikl_link/pages/settings.dart';
import 'package:new_unikl_link/types/info/student_profile.dart';
import 'package:new_unikl_link/types/settings/data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoreActionsPage extends StatelessWidget {
  final Future<SharedPreferences> sharedPrefs;
  final SettingsData settingsData;
  final StudentData studentData;
  final void Function() onLogout;
  final void Function() onLogin;
  final void Function(SettingsData data) onSettingsUpdate;

  const MoreActionsPage({
    super.key,
    required this.sharedPrefs,
    required this.settingsData,
    required this.studentData,
    required this.onLogout,
    required this.onLogin,
    required this.onSettingsUpdate,
  });

  List<Widget> debugButton(
      {required Widget seperator, required BuildContext context}) {
    if (settingsData.debugMode || kDebugMode) {
      return [
        seperator,
        MenuEntry(
          icon: Symbols.experiment,
          label: "Debug Info",
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DebugInfoPage(
                sharedPrefs: sharedPrefs,
                studentData: studentData,
              ),
            ),
          ),
        )
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        MenuEntry(
          icon: Icons.settings,
          label: "Settings",
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SettingsPage(
                prevContext: context,
                sharedPrefs: sharedPrefs,
                settingsData: settingsData,
                onUpdate: (data) => onSettingsUpdate(data),
              ),
            ),
          ),
        ),
        ...debugButton(seperator: SizedBox(height: 8), context: context),
        SizedBox(height: 8),
        MenuEntry(
          icon: Icons.exit_to_app,
          label: "Log Out",
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          iconColor: Theme.of(context).colorScheme.error,
          textStyle: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
          onPressed: () {
            showDialog(
                context: context,
                builder: ((context) => AlertDialog(
                      title: const Text("Logging Out"),
                      content: const Text("Are you sure you want to log out?"),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Cancel")),
                        TextButton(
                          onPressed: () {
                            sharedPrefs.then(
                              (store) {
                                store.remove("timetable");
                                store.remove("eCitieToken");
                                store.remove("personID");
                                store.remove("username");
                                store.remove("password");
                                store.remove("profile");
                              },
                            );
                            Navigator.of(context).pop();
                            Navigator.of(context)
                                .push(
                              MaterialPageRoute<StudentData>(
                                builder: (context) =>
                                    LoginPage(sharedPrefs: sharedPrefs),
                              ),
                            )
                                .then((_) {
                              onLogin();
                            });
                            onLogout();
                          },
                          child: const Text("Confirm"),
                        )
                      ],
                    )));
          },
        ),
      ],
    );
  }
}
