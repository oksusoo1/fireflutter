import 'package:extended/extended.dart';
import 'package:fe/service/app.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget with FirestoreMixin {
  ReportScreen({
    required this.arguments,
    Key? key,
  }) : super(key: key);

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
        onPressed: (ReportModel report) async {
          if (report.target == 'post') {
            AppService.instance.openPostView(id: report.targetId);
          } else if (report.target == 'comment') {
            final doc = await commentCol.doc(report.targetId).get();
            final CommentModel comment =
                CommentModel.fromJson(doc.data() as Json, id: doc.id);
            AppService.instance.openPostView(id: comment.postId);
          } else if (report.target == 'user') {
            // user profiler management
          } else if (report.target == 'image') {
            // file managet
          } else {
            AppService.instance
                .openReportForumMangement(report.target, report.targetId);
          }
        },
      ),
    );
  }
}
