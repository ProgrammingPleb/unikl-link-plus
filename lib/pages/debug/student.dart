import 'package:flutter/material.dart';
import 'package:new_unikl_link/types/info/student_profile.dart';
import 'package:new_unikl_link/utils/normalize.dart';

class StudentDataDebugInfo extends StatelessWidget {
  final StudentData studentData;

  const StudentDataDebugInfo({
    super.key,
    required this.studentData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              "Student Profile",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(
              "ID: ${studentData.id}\n"
              "IC Number: ${studentData.icNumber}\n"
              "Name: ${normalizeName(studentData.name)}\n"
              "Gender: ${normalizeText(studentData.gender)}\n"
              "University Email: ${studentData.uniEmail}\n"
              "Personal Email: ${studentData.selfEmail}\n"
              "Semester Set: ${studentData.semesterSet}\n"
              "Handphone Number: ${studentData.handphoneNum}\n"
              "Home Address: ${normalizeText(studentData.address)}\n"
              "Postcode: ${studentData.postcode}\n"
              "City: ${normalizeText(studentData.city)}\n"
              "Current Semester: ${studentData.currentSemester}\n"
              "Program: ${studentData.programFull}\n"
              "Program Code: ${studentData.programShort}\n"
              "Institute: ${studentData.institute}",
            ),
          ),
        ],
      ),
    );
  }
}
