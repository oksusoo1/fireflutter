import 'package:extended/extended.dart';
import 'package:fe/screens/forum/forum.mixin.dart';
import 'package:fe/screens/job/job.edit.screen.dart';
import 'package:fe/service/app.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({required this.arguments, Key? key}) : super(key: key);
  static final String routeName = '/jobList';

  final Map arguments;

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> with FirestoreMixin, ForumMixin {
  JobListOptionModel options = JobListOptionModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job List'),
        actions: [
          IconButton(
            onPressed: () => AppService.instance.open(JobEditScreen.routeName),
            icon: Icon(Icons.add_circle_outline),
          ),
        ],
        bottom: JobListTitleBottom(
          change: (options) => setState(() => this.options = options),
        ),
      ),
      body: JobListView(
        onError: error,
        options: options,
        onEdit: (post) => AppService.instance.open(
          JobEditScreen.routeName,
          arguments: {'post': post},
        ),
      ),
    );
  }
}

class JobListTitleBottom extends StatefulWidget with PreferredSizeWidget {
  const JobListTitleBottom({
    Key? key,
    required this.change,
  }) : super(key: key);

  final Function(JobListOptionModel) change;

  @override
  Size get preferredSize => Size.fromHeight(200);

  @override
  State<JobListTitleBottom> createState() => _JobListTitleBottomState();
}

class _JobListTitleBottomState extends State<JobListTitleBottom> {
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, child: JobListOptions(change: widget.change));
  }
}
