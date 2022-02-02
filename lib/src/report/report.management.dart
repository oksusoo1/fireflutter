import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';

class ReportManagement extends StatefulWidget {
  ReportManagement({
    Key? key,
    this.padding = const EdgeInsets.all(0),
    required this.onError,
  }) : super(key: key);

  final EdgeInsets padding;
  final Function(dynamic) onError;

  @override
  State<ReportManagement> createState() => _ReportManagementState();
}

class _ReportManagementState extends State<ReportManagement>
    with FirestoreBase {
  final category = TextEditingController();
  final title = TextEditingController();
  final description = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print('report management');
    return FirestoreListView(
      query: reportCol.orderBy('timestamp'),
      itemBuilder: (context, snapshot) {
        final report = ReportModel.fromJson(snapshot.data() as Json);

        return ListTile(
          title: Text(report.reason),
        );
      },
    );
  }
}
