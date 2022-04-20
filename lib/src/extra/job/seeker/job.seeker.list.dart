import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import '../../../../fireflutter.dart';

class JobSeekerList extends StatefulWidget {
  JobSeekerList({this.options, this.onTap, Key? key, this.padding}) : super(key: key);

  final JobSeekerListOptionsModel? options;
  // final Function(String)? onTapChat;
  final Function(JobSeekerModel)? onTap;
  final EdgeInsets? padding;

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
    return FirestoreQueryBuilder(
      query: _query,
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return Text('loading...');
        }

        if (snapshot.hasError) {
          debugPrint("${snapshot.error}");
          return Text('Something went wrong! ${snapshot.error}');
        }
        return ListView.builder(
          itemCount: snapshot.docs.length,
          itemBuilder: (context, index) {
            if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
              snapshot.fetchMore();
            }

            JobSeekerModel seeker = JobSeekerModel.fromJson(
              snapshot.docs[index].data() as Map<String, dynamic>,
              snapshot.docs[index].id,
            );

            return GestureDetector(
              key: ValueKey(seeker.id),
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap != null ? () => widget.onTap!(seeker) : null,
              child: Container(
                margin: EdgeInsets.only(top: 15),
                padding: widget.padding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    UserProfilePhoto(uid: seeker.id, size: 55),
                    SizedBox(width: 16),
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
                    SizedBox(width: 16),
                    Icon(Icons.arrow_right),

                    // if (widget.onTapChat != null)
                    //   IconButton(
                    //     onPressed: () => widget.onTapChat!(seeker.id),
                    //     icon: Icon(Icons.chat_rounded),
                    //   )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
