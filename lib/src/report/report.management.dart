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
        final report =
            ReportModel.fromJson(snapshot.data() as Json, snapshot.reference);

        return ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(report.ref.id),

              Text('Source: ' + report.target),
              UserDoc(
                uid: report.reporterUid,
                builder: (user) {
                  return Text('Reporter: ' +
                      (user.nickname != '' ? user.nickname : 'no_name'));
                },
              ),
              UserDoc(
                uid: report.reporteeUid,
                builder: (user) {
                  return Text('Reportee: ' + user.nickname);
                },
              ),
              Text(report.reason != '' ? report.reason : 'no_reason'),
            ],
          ),
        );
      },
    );
  }
}
