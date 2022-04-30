import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart' as Holo;

/// See README.md for details
class DatePicker extends StatefulWidget {
  const DatePicker({
    required this.initialValue,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  final int initialValue;
  final Function(int) onChanged;
  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime? dateTime;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        dateTime = await Holo.DatePicker.showSimpleDatePicker(
          context,
          titleText: "Select your birthday",
          initialDate: initialDate,
          firstDate: DateTime(1950),
          lastDate: DateTime(2012),
          dateFormat: "MMMM-dd-yyyy",
          locale: Holo.DateTimePickerLocale.en_us,
          looping: false,
        );
        if (dateTime != null) {
          widget.onChanged(int.parse(DateFormat('yyyyMMdd').format(dateTime!)));
        }
        setState(() {});
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(date),
            Icon(Icons.calendar_today),
          ],
        ),
      ),
      behavior: HitTestBehavior.opaque,
    );
  }

  /// To set the initial date on input box.
  ///
  /// If it is set to 0, then 2000 will be the default year.
  DateTime get initialDate {
    if (dateTime != null) {
      return dateTime!;
    } else if (widget.initialValue != 0) {
      String d = widget.initialValue.toString();
      return DateTime(
        int.parse(d.substring(0, 4)),
        int.parse(d.substring(4, 6)),
        int.parse(d.substring(6)),
      );
    } else {
      return DateTime(2000);
    }
  }

  String get date {
    if (dateTime == null) {
      return initialDate.toString().split(' ').first;
    } else {
      return dateTime.toString().split(' ').first;
    }
  }
}
