import 'package:flutter/material.dart';

class MenuEntry extends StatelessWidget {
  final IconData icon;
  final String label;
  final void Function()? onPressed;
  final ButtonStyle? style;
  final TextStyle? textStyle;
  final Color? iconColor;

  const MenuEntry({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.style,
    this.textStyle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: style ??
          FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                icon,
                color: iconColor,
              ),
            ),
            Text(
              label,
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }
}
