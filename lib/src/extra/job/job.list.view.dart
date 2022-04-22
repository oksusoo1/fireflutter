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
    required this.onTap,
  }) : super(key: key);

  final Function onError;
  final Function() onEdit;
  final Function(JobModel) onTap;
  final JobListOptionModel options;

  @override
  State<JobListView> createState() => _JobListViewState();
}

///
class _JobListViewState extends State<JobListView> with FirestoreMixin {
  Query get _searchQuery {
    // print('_serchQuery ${widget.options}');

    final options = widget.options;

    Query query = db.collection('jobs');

    if (options.companyName != '') {
      query = query.where('companyName', isEqualTo: options.companyName);
    }

    if (options.siNm != '') {
      query = query.where('siNm', isEqualTo: options.siNm);
    }
    if (options.sggNm != '') {
      query = query.where('sggNm', isEqualTo: options.sggNm);
    }
    if (options.jobCategory != '') {
      query = query.where('jobCategory', isEqualTo: options.jobCategory);
    }
    if (options.workingHours != -1)
      query = query.where('workingHours', isEqualTo: options.workingHours);
    if (options.workingDays != -1) {
      query = query.where('workingDays', isEqualTo: options.workingDays);
    }
    if (options.accomodation != '') {
      query = query.where('withAccomodation', isEqualTo: options.accomodation);
    }
    if (options.salary != '')
      query = query.where('salary', isEqualTo: options.salary);

    // Only 'status=Y' jobs can be displayed.
    query = query.where('status', isEqualTo: 'Y');

    //
    query = query.orderBy('createdAt', descending: true);

    return query;
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 13,
    );
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

            final job = JobModel.fromJson(
              snapshot.docs[index].data() as Json,
              snapshot.docs[index].id,
            );

            return Column(
              children: [
                GestureDetector(
                  onTap: () => widget.onTap(job),
                  child: ListTile(
                    key: ValueKey(snapshot.docs[index].id),
                    leading: job.files.isNotEmpty
                        ? UploadedImage(
                            url: job.files.first,
                            width: 62,
                            height: 62,
                          )
                        : null,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          JobService.instance.categories[job.category] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          job.companyName + '.',
                          style: style,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(width: 8),
                        Row(
                          children: [
                            Text(job.siNm + ',', style: style),
                            SizedBox(width: 4),
                            Text(job.sggNm, style: style),
                          ],
                        ),
                        Text(
                          'Schedule: ${schedule(job)}',
                          style: style,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Salary: ${job.salary}, Available Slot: ${job.numberOfHiring}, ',
                          style: style,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_right),
                  ),
                ),
                if (job.uid == UserService.instance.uid)
                  TextButton(child: Text('edit'), onPressed: widget.onEdit),
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

  schedule(JobModel job) {
    String s = '';
    if (job.workingHours == 0)
      s += 'flexible hours and ';
    else
      s += '${job.workingHours}hours a day and ';
    if (job.workingDays == 0)
      s += 'flexible days in a week';
    else
      s += '${job.workingDays} days in a week';
    return s;
  }
}
