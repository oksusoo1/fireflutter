import 'package:extended/extended.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class JobSeekerProfileScreen extends StatefulWidget {
  const JobSeekerProfileScreen({
    Key? key,
  }) : super(key: key);
  static final String routeName = '/jobSeekerProfile';

  @override
  State<JobSeekerProfileScreen> createState() => _JobSeekerProfileScreenState();
}

class _JobSeekerProfileScreenState extends State<JobSeekerProfileScreen> {
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
