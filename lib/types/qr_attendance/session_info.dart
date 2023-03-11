import 'package:new_unikl_link/utils/normalize.dart';

class QRSessionInfo {
  late final String staffName;
  late final String subjectName;
  final String group;

  QRSessionInfo({
    required staffName,
    required subjectName,
    required this.group,
  }) {
    this.staffName = normalizeName(staffName);
    this.subjectName = normalizeText(subjectName);
  }

  factory QRSessionInfo.fromJson(Map<String, dynamic> json) {
    return QRSessionInfo(
      staffName: json['SM_STAFF_NAME'],
      subjectName: json['SM_DESC'],
      group: json['SAM_GROUP'],
    );
  }
}
