import 'package:extended/extended.dart';
// import 'package:fe/service/app.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class JobSeekerFormScreen extends StatefulWidget {
  const JobSeekerFormScreen({
    Key? key,
  }) : super(key: key);
  static final String routeName = '/jobSeeker';

  @override
  State<JobSeekerFormScreen> createState() => _JobSeekerFormScreenState();
}

class _JobSeekerFormScreenState extends State<JobSeekerFormScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Seeker'),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            JobSeekerForm(
              onSuccess: () => alert('Success', 'Job seeker profile has been updated!'),
              onError: error,
            ),
            space2xl,
          ],
        ),
      )),
    );
  }
}
