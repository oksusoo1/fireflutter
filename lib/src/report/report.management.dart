import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';

class ReportManagement extends StatelessWidget with FirestoreMixin {
  ReportManagement({
    Key? key,
    this.padding = const EdgeInsets.all(0),
    required this.onError,
    required this.onPressed,
    this.target,
  }) : super(key: key);

  final EdgeInsets padding;
  final String? target;
  final Function(dynamic) onError;
  final Function(ReportModel) onPressed;

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
              UserDoc(
                uid: report.reporterUid,
                builder: (user) {
                  return Text(
                      'Reporter: ' +
                          (user.nickname != '' ? user.nickname : 'no_name'),
                      style: TextStyle(fontSize: 14));
                },
              ),
              UserDoc(
                uid: report.reporteeUid,
                builder: (user) {
                  return Text('Reportee: ' + user.nickname,
                      style: TextStyle(fontSize: 14));
                },
              ),
              if (target == null)
                Text(
                  'Target: ' + report.target,
                  style: TextStyle(fontSize: 14),
                ),
            ],
          ),
          subtitle: Text(
              report.reason != '' ? 'Reason: ' + report.reason : 'no_reason'),
          trailing: IconButton(
            onPressed: () => onPressed(report),
            icon: Icon(
              Icons.open_in_new,
              size: 18,
            ),
          ),
        );
      },
    );
  }
}
