import 'dart:async';

import '../../fireflutter.dart';
import 'package:flutter/material.dart';

class UnitTestLogs extends StatefulWidget {
  const UnitTestLogs({Key? key}) : super(key: key);

  @override
  State<UnitTestLogs> createState() => _UnitTestLogsState();
}

class _UnitTestLogsState extends State<UnitTestLogs> with UnitTestMixin {
  late final StreamSubscription sub;

  @override
  void initState() {
    super.initState();
    sub = model.render.listen((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Success: ${model.success}, '),
            Text(
              'Error: ${model.error}',
              style: TextStyle(
                color: model.error == 0 ? Colors.black : Colors.red,
              ),
            ),
          ],
        ),
        Divider(),
        if (model.waiting)
          Row(
            children: [
              CircularProgressIndicator.adaptive(),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  model.waitingMessage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        ...model.logs.reversed
            .map((e) => Text(
                  e,
                  style: TextStyle(color: e.contains('ERROR:') ? Colors.red : Colors.black),
                ))
            .toList(),
      ],
    );
  }
}
