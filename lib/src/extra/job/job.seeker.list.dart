import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import '../../../fireflutter.dart';

class JobSeekerList extends StatelessWidget with FirestoreMixin {
  JobSeekerList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FirestoreListView(
      query: jobSeekers,
      errorBuilder: (c, o, s) {
        debugPrint('Object; $o');
        debugPrintStack(stackTrace: s);
        return Text(o.toString());
      },
      itemBuilder: (context, snapshot) {
        JobSeekerModel seeker =
            JobSeekerModel.fromJson(snapshot.data() as Map<String, dynamic>, snapshot.id);

        return ListTile(
          title: Text(seeker.industry),
          subtitle: Text(seeker.comment),
        );
      },
    );
  }
}
