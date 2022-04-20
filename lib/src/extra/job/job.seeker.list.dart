import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import '../../../fireflutter.dart';

class JobSeekerList extends StatefulWidget {
  JobSeekerList({this.options, this.onTapChat, this.onTap, Key? key}) : super(key: key);

  final JobSeekerListOptionsModel? options;
  final Function(String)? onTapChat;
  final Function(JobSeekerModel)? onTap;

  @override
  State<JobSeekerList> createState() => _JobSeekerListState();
}

class _JobSeekerListState extends State<JobSeekerList> with FirestoreMixin {
  Query get _query {
    Query q = jobSeekers;

    JobSeekerListOptionsModel options = widget.options ?? JobSeekerListOptionsModel();

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
      loadingBuilder: (context) => Center(
        child: CircularProgressIndicator.adaptive(strokeWidth: 2),
      ),
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

        return GestureDetector(
          key: ValueKey(seeker.id),
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap != null ? () => widget.onTap!(seeker) : null,
          child: Container(
            margin: EdgeInsets.only(top: 15),
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                UserProfilePhoto(uid: seeker.id, size: 55),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UserDoc(
                        uid: seeker.id,
                        builder: (u) => Text(
                          '${u.firstName} ${u.middleName.isNotEmpty ? u.middleName : ''} ${u.lastName} - ${u.gender}',
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('Industry: ${JobService.instance.categories[seeker.industry]}'),
                      SizedBox(height: 4),
                      Text(
                        'Location: ${seeker.siNm}, ${seeker.sggNm}',
                      ),
                    ],
                  ),
                ),
                if (widget.onTapChat != null)
                  IconButton(
                    onPressed: () => widget.onTapChat!(seeker.id),
                    icon: Icon(Icons.chat_rounded),
                  )
              ],
            ),
          ),
        );
      },
    );
  }
}
