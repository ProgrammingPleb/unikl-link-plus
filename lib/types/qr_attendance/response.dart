import 'package:new_unikl_link/types/qr_attendance/session_info.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class QRAttendanceResponse {
  final String status;
  final String? errorMessage;
  final QRSessionInfo? sessionInfo;

  QRAttendanceResponse(
      {required this.status, this.errorMessage, this.sessionInfo});

  factory QRAttendanceResponse.fromJson(Map<String, dynamic> json) {
    String? errMsg;
    QRSessionInfo? qrSessionInfo;

    if (json.containsKey("errmsg")) {
      errMsg = json['errmsg'];
    }
    if (json.containsKey("sessionInfo")) {
      try {
        qrSessionInfo = QRSessionInfo.fromJson(
            Map<String, dynamic>.from(json['sessionInfo']));
      } catch (e, stackTrace) {
        Sentry.captureException(
          e,
          stackTrace: stackTrace,
        );
      }
    }
    return QRAttendanceResponse(
      status: json['status'],
      errorMessage: errMsg,
      sessionInfo: qrSessionInfo,
    );
  }
}
