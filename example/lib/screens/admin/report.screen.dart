import 'package:extended/extended.dart';
import 'package:fe/service/app.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({required this.arguments, Key? key}) : super(key: key);

  static const String routeName = '/report';
  final Map arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Management'),
      ),
      body: ReportManagement(
        target: arguments['target'],
        onError: error,
        onPressed: (ReportModel report) {
          AppService.instance.openReportForumMangement(report.target, report.targetId);
        },
      ),
    );
  }
}
