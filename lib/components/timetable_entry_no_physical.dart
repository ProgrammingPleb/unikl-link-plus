import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_unikl_link/types/timetable/entry.dart';

class TimetableEntryNoPhysical extends StatelessWidget {
  final TimetableDayEntry entry;
  final DateFormat timeFormat;
  final bool fastingEnabled;

  const TimetableEntryNoPhysical({
    super.key,
    required this.entry,
    required this.timeFormat,
    required this.fastingEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            "${timeFormat.format(entry.getStartTimeObject(fastingEnabled))} "
            "- ${timeFormat.format(entry.getEndTimeObject(fastingEnabled))}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 60,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 5,
                fit: FlexFit.tight,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              entry.subjectCode,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              " (${entry.group})",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            entry.subjectName,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontSize: 16,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Center(
                    child: Text(
                      "Online",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
