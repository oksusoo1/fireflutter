import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import '../../../fireflutter.dart';

class JobSeekerList extends StatefulWidget {
  JobSeekerList({required this.options, Key? key}) : super(key: key);

  final JobSeekerListOptionsModel options;

  @override
  State<JobSeekerList> createState() => _JobSeekerListState();
}

class _JobSeekerListState extends State<JobSeekerList> with FirestoreMixin {
  Query get _query {
    Query q = jobSeekers;

    JobSeekerListOptionsModel options = widget.options;

    if (options.siNm != '') {
      q = q.where('siNm', isEqualTo: options.siNm);
    }
    if (options.sggNm != '') {
      q = q.where('sggNm', isEqualTo: options.sggNm);
    }

    /// industry filter.
    if (options.industry.isNotEmpty) {
      q = q.where('industry', isEqualTo: options.industry);
    }

    return q;
  }

  @override
  Widget build(BuildContext context) {
    return FirestoreListView(
      query: _query,
      loadingBuilder: (context) => Center(child: Text('loading ...')),
      errorBuilder: (c, o, s) {
        debugPrint('Object; $o');
        debugPrintStack(stackTrace: s);
        return Text(o.toString());
      },
      itemBuilder: (context, snapshot) {
        JobSeekerModel seeker = JobSeekerModel.fromJson(
          snapshot.data() as Map<String, dynamic>,
          snapshot.id,
        );

        /// todo: job seeker list item ui
        ///  - show seeker's profile image
        ///  - show chat button for contact
        ///  - show details (first name, middle name, last name, gender, proficiency, comment)
        return ListTile(
          title: Text(
            '${JobService.instance.categories[seeker.industry]} - ${seeker.siNm},${seeker.sggNm}',
          ),
          subtitle: Text(seeker.comment),
        );
      },
    );
  }
}
