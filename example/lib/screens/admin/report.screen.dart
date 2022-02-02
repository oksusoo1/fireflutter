import 'package:extended/extended.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Management'),
      ),
      body: ReportManagement(
        onError: error,
      ),
    );
  }
}
