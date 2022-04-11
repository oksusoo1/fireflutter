import 'package:fe/screens/forum/forum.mixin.dart';
import './job.edit.screen.dart';
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

class _JobListScreenState extends State<JobListScreen>
    with FirestoreMixin, ForumMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job List'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () =>
                    AppService.instance.open(JobEditScreen.routeName),
                child: Text('Create a job opening'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
