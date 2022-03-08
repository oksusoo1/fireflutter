import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShortDate extends StatelessWidget {
  const ShortDate(
    this.timestamp, {
    this.style,
    this.padding = const EdgeInsets.all(0),
    Key? key,
  }) : super(key: key);

  final int timestamp;
  final TextStyle? style;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final today = DateTime.now();
    bool re;
    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      re = true;
    } else {
      re = false;
    }

    return Padding(
      padding: padding,
      child: Text(
        re
            ? DateFormat.jm().format(date).toLowerCase()
            : DateFormat.yMd().format(date),
        style: style,
      ),
    );
  }
}
