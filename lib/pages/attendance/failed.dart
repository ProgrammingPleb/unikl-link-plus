import 'package:flutter/material.dart';
import 'package:new_unikl_link/types/qr_attendance/response.dart';

class AttendanceFailed extends StatefulWidget {
  final QRAttendanceResponse qrResp;

  const AttendanceFailed({Key? key, required this.qrResp}) : super(key: key);

  @override
  State<AttendanceFailed> createState() => _AttendanceFailedState();
}

class _AttendanceFailedState extends State<AttendanceFailed> {
  String errorMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Self Attendance")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.assignment_late,
              size: 60,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 30),
              child: Text(
                "Self Attendance Failed",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    if (widget.qrResp.errorMessage == null) {
      errorMessage = "Self attendance was not successful.";
    } else {
      errorMessage = widget.qrResp.errorMessage!;
    }
    super.initState();
  }
}
