class QRAttendanceData {
  final String session;
  final String datetime;

  QRAttendanceData({
    required this.session,
    required this.datetime,
  });

  factory QRAttendanceData.fromJson(Map<String, dynamic> json) {
    return QRAttendanceData(
      session: json['session'],
      datetime: json['datetime'],
    );
  }
}
