import 'package:new_unikl_link/types/subject.dart';

List<SemesterSubject> processSubjects(List<dynamic> data) {
  List<SemesterSubject> subjects = [];

  for (dynamic subject in data) {
    subjects.add(SemesterSubject.fromJson(subject));
  }

  return subjects;
}
