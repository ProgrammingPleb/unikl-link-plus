import 'package:flutter/material.dart';

class InfoEntry extends StatelessWidget {
  final Icon icon;
  final String label;
  final List<Widget> data;

  const InfoEntry({
    super.key,
    required this.icon,
    required this.label,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        SizedBox(
          width: 12,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            ...data,
          ],
        ),
      ],
    );
  }
}
