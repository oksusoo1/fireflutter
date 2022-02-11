import 'package:extended/extended.dart';
import 'package:fe/service/app.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({Key? key}) : super(key: key);

  static const String routeName = '/report';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Management'),
      ),
      body: ReportManagement(
        target: Get.arguments['target'],
        onError: error,
        onPressed: (ReportModel report) {
          AppController.of.openReportForumMangement(report.target, report.targetId);
        },
      ),
    );
  }
}
