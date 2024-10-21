import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:new_unikl_link/pages/attendance/failed.dart';
import 'package:new_unikl_link/pages/attendance/success.dart';
import 'package:new_unikl_link/server/query.dart';
import 'package:new_unikl_link/server/urls.dart';
import 'package:new_unikl_link/types/info/student_profile.dart';
import 'package:new_unikl_link/types/qr_attendance/data.dart';
import 'package:new_unikl_link/types/qr_attendance/response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelfAttendancePage extends StatelessWidget {
  final ECitieURLs eCitieURL = ECitieURLs();
  final ECitieQuery eCitieQ = ECitieQuery();
  final StudentData studentData;
  final Future<SharedPreferences> storeFuture;
  final MobileScannerController controller = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
    detectionTimeoutMs: 1000,
    formats: [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  SelfAttendancePage({
    super.key,
    required this.studentData,
    required this.storeFuture,
  });

  @override
  Widget build(BuildContext context) {
    void processQR(List<Barcode> barcodes) {
      if (barcodes == [] || barcodes[0].rawValue == null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Unable to scan the QR code, please try again!"),
          ),
        );
      } else {
        QRAttendanceData qr =
            QRAttendanceData.fromJson(jsonDecode(barcodes[0].rawValue!));
        storeFuture.then((store) {
          http.post(
            Uri.parse(eCitieURL.selfAttendance(qr.session, qr.datetime,
                store.getString("eCitieToken")!, studentData.id)),
            headers: {"content-type": "application/x-www-form-urlencoded"},
          ).then((resp) {
            QRAttendanceResponse qrResp =
                QRAttendanceResponse.fromJson(jsonDecode(resp.body));
            if (qrResp.status == "0") {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => AttendanceFailed(
                            qrResp: qrResp,
                          )))
                  .then((value) => Navigator.of(context).pop());
            } else {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => AttendanceSuccess(
                            qrResp: qrResp,
                          )))
                  .then((value) => Navigator.of(context).pop());
            }
          });
        });
      }
    }

    return Scaffold(
        body: CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverAppBar.large(
          title: const Text(
            "Self Attendance",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 50, 15, 20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Text(
                        "Ensure that the attendance QR code is in the frame."),
                  ),
                  Container(
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    clipBehavior: Clip.hardEdge,
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.8,
                    child: MobileScanner(
                      controller: controller,
                      fit: BoxFit.cover,
                      onDetect: ((capture) {
                        processQR(capture.barcodes);
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: ElevatedButton(
                      onPressed: () {
                        final ImagePicker imagePicker = ImagePicker();
                        imagePicker
                            .pickImage(source: ImageSource.gallery)
                            .then((image) async {
                          if (image != null) {
                            BarcodeCapture? qrData =
                                await controller.analyzeImage(image.path);
                            if (qrData != null) {
                              processQR(qrData.barcodes);
                            } else {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Unable to process the attendance "
                                          "QR code!")));
                            }
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 5.0,
                        textStyle: const TextStyle(color: Colors.white),
                      ),
                      child: const Text("Select Image"),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    ));
  }
}
