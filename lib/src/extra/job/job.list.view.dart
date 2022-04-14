import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';

class JobListView extends StatefulWidget {
  const JobListView({
    Key? key,
    required this.onError,
    required this.options,
    required this.onEdit,
  }) : super(key: key);

  final Function onError;
  final Function(PostModel) onEdit;
  final JobListOptionModel options;

  @override
  State<JobListView> createState() => _JobListViewState();
}

///
/// TODO - Remove 'category'
/// TODO - Make one field on location ( siNm + sggNm ).
/// TODO - Search combinatino: job category, location, working days, accommodation, createdAt.
///
class _JobListViewState extends State<JobListView> with FirestoreMixin {
  Query get _searchQuery {
    print('_serchQuery ${widget.options}');

    final options = widget.options;

    Query query = postCol;

    bool added = false;

    if (options.siNm != '') {
      query = query.where('siNm', isEqualTo: options.siNm);
      added = true;
    }
    if (options.sggNm != '') {
      query = query.where('sggNm', isEqualTo: options.sggNm);
      added = true;
    }
    if (options.jobCategory != '') {
      query = query.where('jobCategory', isEqualTo: options.jobCategory);
      added = true;
    }
    if (options.workingHours != -1) {
      query = query.where('workingHours', isEqualTo: options.workingHours);
      added = true;
    }
    if (options.workingDays != -1) {
      query = query.where('workingDays', isEqualTo: options.workingDays);
      added = true;
    }
    if (options.accomodation != '') {
      query = query.where('withAccomodation', isEqualTo: options.accomodation);
      added = true;
    }
    if (options.salary != '') {
      query = query.where('salary', isEqualTo: options.salary);
      added = true;
    }

    if (added == false) {
      query = query.where('category', isEqualTo: JobService.instance.jobOpenings);
    }

    query = query.orderBy('createdAt', descending: true);
    return query;
  }

  @override
  Widget build(BuildContext context) {
    return FirestoreQueryBuilder(
      query: _searchQuery,
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

            // Json data = snapshot.docs[index].data() as Json;

            final job = JobModel.fromJson(
              snapshot.docs[index].data() as Json,
              snapshot.docs[index].id,
            );

            return Column(
              children: [
                // if (index == 0) JobListOptions(),
                ListTile(
                  key: ValueKey(snapshot.docs[index].id),
                  // margin: EdgeInsets.only(top: index == 0 ? 16 : 0),
                  // padding:
                  //     EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: job.files.isNotEmpty
                      ? UploadedImage(
                          url: job.files.first,
                          width: 62,
                          height: 62,
                        )
                      : null,
                  // title: Text(data['jobDescription']),
                  title: Text(job.description),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('TODO: display job created at time'),
                  ),
                ),
                Divider(
                  color: Colors.grey.shade400,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
