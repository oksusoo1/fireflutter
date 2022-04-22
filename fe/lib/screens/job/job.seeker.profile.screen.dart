import 'package:extended/extended.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class JobSeekerProfileFormScreen extends StatefulWidget {
  const JobSeekerProfileFormScreen({
    Key? key,
  }) : super(key: key);
  static final String routeName = '/jobSeekerProfileForm';

  @override
  State<JobSeekerProfileFormScreen> createState() =>
      _JobSeekerProfileFormScreenState();
}

class _JobSeekerProfileFormScreenState
    extends State<JobSeekerProfileFormScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Seeker Profile'),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            JobSeekerProfileForm(
              onSuccess: () =>
                  alert('Success', 'Job seeker profile has been updated!'),
              onError: error,
            ),
            space2xl,
          ],
        ),
      )),
    );
  }
}
