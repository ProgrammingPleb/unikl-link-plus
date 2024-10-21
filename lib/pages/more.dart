import 'package:flutter/material.dart';
import 'package:new_unikl_link/components/menu_entry.dart';

class MoreActionsPage extends StatelessWidget {
  const MoreActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        MenuEntry(icon: Icons.settings, label: "Settings"),
        SizedBox(height: 8),
        MenuEntry(icon: Icons.exit_to_app, label: "Log Out"),
      ],
    );
  }
}
