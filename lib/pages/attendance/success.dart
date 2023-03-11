import 'package:flutter/material.dart';
import 'package:new_unikl_link/types/qr_attendance/response.dart';

class AttendanceSuccess extends StatefulWidget {
  final QRAttendanceResponse qrResp;

  const AttendanceSuccess({Key? key, required this.qrResp}) : super(key: key);

  @override
  State<AttendanceSuccess> createState() => _AttendanceSuccessState();
}

class _AttendanceSuccessState extends State<AttendanceSuccess> {
  List<Widget> details = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Self Attendance")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.assignment_turned_in,
              size: 60,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 30),
              child: Text(
                "Self Attendance Successful",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Column(children: details),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    if (widget.qrResp.sessionInfo == null) {
      details = [
        const Text("Self attendance was recorded."),
      ];
    } else {
      details = [
        Text("Lecturer: ${widget.qrResp.sessionInfo?.staffName}"),
        Text("Subject: ${widget.qrResp.sessionInfo?.subjectName}"),
        Text("Group: ${widget.qrResp.sessionInfo?.group}"),
      ];
    }
    super.initState();
  }
}
