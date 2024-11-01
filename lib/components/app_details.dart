import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppDetails extends StatefulWidget {
  const AppDetails({super.key});

  @override
  State<AppDetails> createState() => _AppDetailsState();
}

class _AppDetailsState extends State<AppDetails> {
  final double logoSize = 128;
  String versionCode = "";

  void showVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      versionCode = packageInfo.version;
    });
  }

  @override
  void initState() {
    showVersion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: logoSize,
          height: logoSize,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              "resources/logo.png",
            ),
          ),
        ),
        SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "UniKL Link+",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize:
                    MediaQuery.maybeTextScalerOf(context)?.scale(28) ?? 28,
              ),
            ),
            Text("By ProgrammingPleb"),
            SizedBox(height: 6),
            Text("Version: $versionCode")
          ],
        )
      ],
    );
  }
}
