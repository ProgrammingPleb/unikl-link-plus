import 'package:intl/intl.dart';

final DateFormat eCitieDateFormat = DateFormat("MMM d, yyyy, h:mm:ss a");

class SemesterSubject {
  final String code;
  final String name;
  final int creditHours;
  final String program;
  final String status;
  final int? passMark;
  final String exam;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final String lectureGroup;

  SemesterSubject({
    this.code = "",
    this.name = "",
    this.creditHours = 0,
    this.program = "",
    this.status = "",
    this.passMark,
    this.exam = "",
    DateTime? createdDate,
    DateTime? updatedDate,
    this.lectureGroup = "",
  })  : createdDate = createdDate ?? DateTime(1970),
        updatedDate = updatedDate ?? DateTime(1970);

  factory SemesterSubject.fromJson(Map<String, dynamic> data) {
    return SemesterSubject(
      code: data["SM_CODE"],
      name: data["SM_DESC"],
      creditHours: data["SM_HOURS"],
      program: data["SM_PROGRAM"],
      status: data["SM_STATUS"],
      passMark: data["SM_PASS_MARK"],
      exam: data["SM_EXAM"],
      createdDate: data["SM_CREATED_DATE"] != null
          ? eCitieDateFormat.parse(data["SM_CREATED_DATE"])
          : null,
      updatedDate: data["SM_UPDATED_DATE"] != null
          ? eCitieDateFormat.parse(data["SM_UPDATED_DATE"])
          : null,
      lectureGroup: data["SR_LECT_GROUP"],
    );
  }
}
