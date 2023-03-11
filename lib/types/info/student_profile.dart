import 'dart:convert';
import 'package:new_unikl_link/utils/normalize.dart' as normalize;

class StudentData {
  final String id;
  final String icNumber;
  final String uniEmail;
  final String selfEmail;
  final String name;
  final String semesterSet;
  final String branchCode;
  final String? handphoneNum;
  final String address;
  final String postcode;
  final String city;
  final int currentSemester;
  final String programFull;
  final String programShort;
  final String institute;
  final String gender;

  StudentData({
    required this.id,
    required this.icNumber,
    required this.uniEmail,
    required this.selfEmail,
    required this.name,
    required this.semesterSet,
    required this.branchCode,
    required this.handphoneNum,
    required this.address,
    required this.postcode,
    required this.city,
    required this.currentSemester,
    required this.programFull,
    required this.programShort,
    required this.institute,
    required this.gender,
  });

  factory StudentData.fromJson(Map<String, dynamic> json) {
    return StudentData(
      id: json['UNIKL_ID'],
      icNumber: json['IC_NO'],
      uniEmail: json['EMAIL_ADDR'],
      selfEmail: json['EMAIL_ADDR_PERSONAL'],
      name: json['NAME'],
      semesterSet: json['SEMESTER_SET'],
      branchCode: json['BRANCH_CODE'],
      handphoneNum: json['HANDPHONE_NO'],
      address: json['ADDRESS'],
      postcode: json['POSTCODE'],
      city: json['CITY'],
      currentSemester: json['CURRENT_SEMESTER'],
      programFull: json['PROGRAM'],
      programShort: json['PROGRAM_SHORT'],
      institute: json['INSTITUTE'],
      gender: json['GENDER'],
    );
  }

  String toJson() {
    return jsonEncode({
      "UNIKL_ID": id,
      "IC_NO": icNumber,
      "EMAIL_ADDR": uniEmail,
      "EMAIL_ADDR_PERSONAL": selfEmail,
      "NAME": name,
      "SEMESTER_SET": semesterSet,
      "BRANCH_CODE": branchCode,
      "HANDPHONE_NO": handphoneNum,
      "ADDRESS": address,
      "POSTCODE": postcode,
      "CITY": city,
      "CURRENT_SEMESTER": currentSemester,
      "PROGRAM": programFull,
      "PROGRAM_SHORT": programShort,
      "INSTITUTE": institute,
      "GENDER": gender,
    });
  }

  String normalizeName() {
    return normalize.normalizeName(name);
  }
}
