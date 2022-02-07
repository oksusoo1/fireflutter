import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import '../../fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';

class ReportManagement extends StatelessWidget with FirestoreMixin {
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
  Widget build(BuildContext context) {
    Query? query;
    CollectionReference q = reportCol;
    if (target != null) {
      query = q.where('target', isEqualTo: target);
    }

    if (query != null) {
      query = query.orderBy('timestamp');
    } else {
      query = q.orderBy('timestamp');
    }
    return FirestoreListView(
      query: query,
      itemBuilder: (context, snapshot) {
        final report =
            ReportModel.fromJson(snapshot.data() as Json, snapshot.reference);

        return ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Source: ' + report.target),
              UserFutureDoc(
                uid: report.reporterUid,
                builder: (user) {
                  return Text('Reporter: ' +
                      (user.nickname != '' ? user.nickname : 'no_name'));
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
          trailing: IconButton(
            onPressed: () {
              print('goto');
            },
            icon: Icon(Icons.open_in_new),
          ),
        );
      },
    );
  }
}
