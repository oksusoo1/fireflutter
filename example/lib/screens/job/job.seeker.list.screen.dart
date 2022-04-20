import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

// job seeker search
// locations (province, city)
// category (industry)
class JobSeekerListScreen extends StatelessWidget {
  const JobSeekerListScreen({
    Key? key,
  }) : super(key: key);

  static final String routeName = '/jobSeeker';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Seeker List'),
      ),
      body: JobSeekerList(),
    );
  }
}
