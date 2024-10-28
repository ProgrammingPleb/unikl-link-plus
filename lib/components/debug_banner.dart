import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DebugBanner extends StatelessWidget {
  final bool enabled;

  const DebugBanner({
    super.key,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    if (enabled || kDebugMode) {
      return Container(
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.errorContainer),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "You are currently in debug mode!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer),
            ),
          ),
        ),
      );
    }
    return Column();
  }
}
