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
import 'package:material_symbols_icons/symbols.dart';

class SelfAttendancePage extends StatefulWidget {
  final StudentData studentData;
  final Future<SharedPreferences> storeFuture;

  const SelfAttendancePage({
    super.key,
    required this.studentData,
    required this.storeFuture,
  });

  @override
  State<StatefulWidget> createState() => _SelfAttendancePageState();
}

class _SelfAttendancePageState extends State<SelfAttendancePage> {
  final ECitieURLs eCitieURL = ECitieURLs();
  final ECitieQuery eCitieQ = ECitieQuery();
  final MobileScannerController controller = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
    detectionTimeoutMs: 1000,
    formats: [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  double zoomFactor = 0.0;
  int scanStatus = 0;

  void updateScanStatus(int status) {
    setState(() {
      scanStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    void processQR(List<Barcode> barcodes) {
      void showErrorSnackbar(String errorMsg) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
          ),
        );
        updateScanStatus(0);
      }

      updateScanStatus(1);
      if (barcodes == [] || barcodes[0].rawValue == null) {
        showErrorSnackbar("Unable to scan the QR code, please try again!");
      } else {
        updateScanStatus(2);
        try {
          jsonDecode(barcodes[0].rawValue!);
        } catch (_) {
          showErrorSnackbar("Invalid QR code, please try again!");
          return;
        }
        QRAttendanceData qr =
            QRAttendanceData.fromJson(jsonDecode(barcodes[0].rawValue!));
        widget.storeFuture.then((store) {
          http.post(
            Uri.parse(eCitieURL.selfAttendance(qr.session, qr.datetime,
                store.getString("eCitieToken")!, widget.studentData.id)),
            headers: {"content-type": "application/x-www-form-urlencoded"},
          ).then((resp) {
            QRAttendanceResponse qrResp =
                QRAttendanceResponse.fromJson(jsonDecode(resp.body));
            if (context.mounted) {
              if (qrResp.status == "0") {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => AttendanceFailed(
                              qrResp: qrResp,
                            )))
                    .then((value) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                });
              } else {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => AttendanceSuccess(
                              qrResp: qrResp,
                            )))
                    .then((value) {
                  if (context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                });
              }
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
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                        "Ensure that the attendance QR code is in the frame."),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        Text("Status:"),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: getScanStatus(scanStatus),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    child: Container(
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
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        Text("Zoom:"),
                        Slider(
                          inactiveColor: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withAlpha(100),
                          value: zoomFactor,
                          onChanged: (value) {
                            setState(() {
                              zoomFactor = value;
                              controller.setZoomScale(zoomFactor);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
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
                            } else if (context.mounted) {
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

List<Widget> getScanStatus(int status) {
  switch (status) {
    case 0:
      return [
        Icon(Icons.qr_code),
        SizedBox(
          width: 10,
        ),
        Text("Waiting for a QR code."),
      ];
    case 1:
      return [
        Icon(Symbols.memory_alt),
        SizedBox(
          width: 10,
        ),
        Text("Processing QR code."),
      ];
    case 2:
      return [
        Icon(Symbols.host),
        SizedBox(
          width: 10,
        ),
        Text("Waiting for acknowledgement."),
      ];
    default:
      return [
        Icon(Symbols.question_mark),
        SizedBox(
          width: 10,
        ),
        Text("Unknown status."),
      ];
  }
}
