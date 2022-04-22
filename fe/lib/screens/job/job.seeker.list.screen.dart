import 'package:fe/screens/job/job.seeker.profile.view.screen.dart';
import 'package:fe/service/app.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class JobSeekerListScreen extends StatefulWidget {
  const JobSeekerListScreen({
    Key? key,
  }) : super(key: key);

  static final String routeName = '/jobSeekerList';

  @override
  State<JobSeekerListScreen> createState() => _JobSeekerListScreenState();
}

class _JobSeekerListScreenState extends State<JobSeekerListScreen> {
  JobSeekerListOptionsModel options = JobSeekerListOptionsModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Seeker List'),
        bottom: JobSeekerListTitleBottom(
          change: (options) => setState(() => this.options = options),
        ),
      ),
      body: JobSeekerList(
        options: options,
        onTap: (seeker) => AppService.instance.open(
          JobSeekerProfileViewScreen.routeName,
          arguments: {'profile': seeker},
        ),
      ),
    );
  }
}

class JobSeekerListTitleBottom extends StatefulWidget with PreferredSizeWidget {
  const JobSeekerListTitleBottom({
    Key? key,
    required this.change,
  }) : super(key: key);

  final Function(JobSeekerListOptionsModel) change;

  @override
  Size get preferredSize => Size.fromHeight(100);

  @override
  State<JobSeekerListTitleBottom> createState() =>
      _JobSeekerListTitleBottomState();
}

class _JobSeekerListTitleBottomState extends State<JobSeekerListTitleBottom> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: JobSeekerListOptions(change: widget.change));
  }
}
