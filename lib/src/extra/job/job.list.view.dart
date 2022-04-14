import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';

class JobListView extends StatefulWidget {
  const JobListView({
    Key? key,
    required this.onError,
    required this.options,
  }) : super(key: key);

  final Function onError;
  final JobListOptionModel options;

  @override
  State<JobListView> createState() => _JobListViewState();
}

class _JobListViewState extends State<JobListView> with FirestoreMixin {
  Query get _searchQuery {
    print('_serchQuery ${widget.options}');

    final options = widget.options;

    Query q = postCol.where('category', isEqualTo: JobService.instance.jobOpenings);

    if (options.jobCategory != '') {
      q.where('jobCategory', isEqualTo: options.jobCategory);
    }

    if (options.sort == 'salary') {
      q = q.orderBy('salary', descending: true);
    }
    if (options.sort == 'workingDays') {
    } else {
      q = q.orderBy('createdAt', descending: true);
    }

    return q;
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
          return Text('Something went wrong! ${snapshot.error}');
        }
        return ListView.builder(
          itemCount: snapshot.docs.length,
          itemBuilder: (context, index) {
            if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
              snapshot.fetchMore();
            }

            Json data = snapshot.docs[index].data() as Json;

            final post = PostModel.fromJson(
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
                  leading: post.files.isNotEmpty
                      ? UploadedImage(
                          url: post.files.first,
                          width: 62,
                          height: 62,
                        )
                      : null,
                  title: Text(data['jobDescription']),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(post.shortDateTime),
                  ),
                  trailing: Icon(
                    post.open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey,
                  ),
                  onTap: () => setState(() => post.open = !post.open),
                ),
                if (post.open)
                  // PagePadding(
                  //   children: [
                  Text('post id; ${post.id}'),
                //   ],
                // ),
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
