import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import '../../../fireflutter.dart';

class JobSeekerList extends StatefulWidget {
  JobSeekerList({this.options, this.onTapChat, Key? key}) : super(key: key);

  final JobSeekerListOptionsModel? options;
  final Function(String)? onTapChat;

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

        return JobSeekerListItem(
          seeker: seeker,
          key: ValueKey(seeker.id),
          onTapChat: widget.onTapChat != null ? () => widget.onTapChat!(seeker.id) : null,
        );
      },
    );
  }
}

class JobSeekerListItem extends StatefulWidget {
  const JobSeekerListItem({
    required this.seeker,
    this.onTapChat,
    Key? key,
  }) : super(key: key);

  final JobSeekerModel seeker;
  final Function()? onTapChat;

  @override
  State<JobSeekerListItem> createState() => _JobSeekerListItemState();
}

class _JobSeekerListItemState extends State<JobSeekerListItem> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => open = !open),
      child: Container(
        margin: EdgeInsets.only(top: 10),
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                UserProfilePhoto(uid: widget.seeker.id, size: 55),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UserDoc(
                        uid: widget.seeker.id,
                        builder: (u) => Text(
                          '${u.firstName} ${u.middleName.isNotEmpty ? u.middleName : ''} ${u.lastName} - ${u.gender}',
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('Industry: ${JobService.instance.categories[widget.seeker.industry]}'),
                      SizedBox(height: 4),
                      Text(
                        'Location: ${widget.seeker.siNm}, ${widget.seeker.sggNm}',
                      ),
                    ],
                  ),
                ),
                if (widget.onTapChat != null)
                  IconButton(onPressed: widget.onTapChat, icon: Icon(Icons.chat_rounded))
              ],
            ),
            SizedBox(height: 10),
            if (open) ...[
              Text('Proficiency: ${widget.seeker.proficiency}'),
              SizedBox(height: 5),
              Text('Comment: ${widget.seeker.comment}'),
            ]
          ],
        ),
      ),
    );
  }
}
