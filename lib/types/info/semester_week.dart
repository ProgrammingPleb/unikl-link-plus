import 'package:intl/intl.dart';
import 'package:new_unikl_link/utils/normalize.dart';

class SemesterWeek {
  late final String name;
  late final String type;
  late final int number;
  late final DateTime startTime;
  late final DateTime endTime;

  SemesterWeek(Map<String, dynamic> data) {
    DateFormat dateFormat = DateFormat("MMM d, yyyy, h:mm:ss a");

    name = normalizeText(data['SD_EVENT']);
    type = normalizeText(data['SD_EVENT_TYPE']);
    if (type == "Semester Break" || type == "Exam") {
      number = 1;
    } else {
      number = data['SD_WEEK'];
    }
    startTime = dateFormat.parse(data['SD_START']);
    endTime = dateFormat.parse(data['SD_END']);
  }
}
