import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShortDate extends StatelessWidget {
  const ShortDate(
    this.timestamp, {
    Key? key,
  }) : super(key: key);

  final int timestamp;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final today = DateTime.now();
    bool re;
    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      re = true;
    } else {
      re = false;
    }

    return Text(re ? DateFormat.jm().format(date) : DateFormat.yMd().format(date));
  }
}
