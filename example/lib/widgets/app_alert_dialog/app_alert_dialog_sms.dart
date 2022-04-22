import 'package:example/services/functions.dart';
import 'package:flutter/material.dart';

class SmsText extends StatelessWidget {
  const SmsText({
    Key? key,
    required this.title,
    required this.number,
    this.padding,
    this.width,
    this.fontSize = 12,
  }) : super(key: key);

  final String title;
  final String number;
  final EdgeInsets? padding;
  final double? width;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => launchURL("sms://$number"),
      child: Container(
        padding: padding,
        width: width,
        color: Colors.grey.shade100,
        child: Text(
          title,
          style: TextStyle(fontSize: fontSize, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
