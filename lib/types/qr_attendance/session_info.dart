class QRSessionInfo {
  late final String staffName;
  late final String subjectName;
  final String group;

  QRSessionInfo({
    required staffName,
    required subjectName,
    required this.group,
  }) {
    this.staffName = normalizeString(staffName);
    this.subjectName = normalizeString(subjectName);
  }

  factory QRSessionInfo.fromJson(Map<String, dynamic> json) {
    return QRSessionInfo(
      staffName: json['SM_STAFF_NAME'],
      subjectName: json['SM_DESC'],
      group: json['SAM_GROUP'],
    );
  }

  String normalizeString(String text) {
    String tempName = "";
    text.split(" ").forEach((element) {
      String namePart = element.toLowerCase();
      if (namePart != "bin" && namePart != "binti") {
        tempName += "${namePart[0].toUpperCase()}${namePart.substring(1)} ";
      } else {
        tempName += "$namePart ";
      }
    });
    return tempName.trim();
  }
}
