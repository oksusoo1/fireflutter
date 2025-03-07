import 'package:extended/extended.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PointHistoryScreen extends StatelessWidget {
  const PointHistoryScreen({Key? key}) : super(key: key);

  static const String routeName = '/pointHistory';

  @override
  Widget build(BuildContext context) {
    final d = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: Text('Point History')),
      body: Container(
        child: PointHistory(
          year: d.year,
          month: d.month,
          onError: error,
        ),
      ),
    );
  }
}
