import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import '../../fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';

class ReportManagement extends StatefulWidget {
  ReportManagement({
    Key? key,
    this.padding = const EdgeInsets.all(0),
    required this.onError,
    this.target,
  }) : super(key: key);

  final EdgeInsets padding;
  final Function(dynamic) onError;
  final String? target;

  @override
  State<ReportManagement> createState() => _ReportManagementState();
}

class _ReportManagementState extends State<ReportManagement> with FirestoreBase {
  Query? query;
  @override
  void initState() {
    super.initState();
    CollectionReference q = reportCol;
    if (widget.target != null) {
      query = q.where('target', isEqualTo: widget.target);
    }

    if (query != null) {
      query = query!.orderBy('timestamp');
    } else {
      query = q.orderBy('timestamp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FirestoreListView(
      query: query!,
      itemBuilder: (context, snapshot) {
        final report = ReportModel.fromJson(snapshot.data() as Json, snapshot.reference);

        return ExpansionTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Source: ' + report.target),
              UserFutureDoc(
                uid: report.reporterUid,
                builder: (user) {
                  return Text('Reporter: ' + (user.nickname != '' ? user.nickname : 'no_name'));
                },
              ),
              UserFutureDoc(
                uid: report.reporteeUid,
                builder: (user) {
                  return Text('Reportee: ' + user.nickname);
                },
              ),
              Text(report.reason != '' ? report.reason : 'no_reason'),
            ],
          ),
          children: [
            ElevatedButton(
              onPressed: () {
                print('admin actions');
              },
              child: const Text('admin action'),
            ),
          ],
        );
      },
    );
  }
}
