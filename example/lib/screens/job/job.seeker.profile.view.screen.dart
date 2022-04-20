import 'package:extended/extended.dart';
import 'package:fe/service/app.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class JobSeekerProfileViewScreen extends StatelessWidget {
  const JobSeekerProfileViewScreen({
    required this.arguments,
    Key? key,
  }) : super(key: key);
  static final String routeName = '/jobSeekerProfileView';

  final Map arguments;

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
            JobSeekerProfileView(
              seeker: arguments['profile'],
              onChat: (uid) => AppService.instance.openChatRoom(uid),
            ),
            space2xl,
          ],
        ),
      )),
    );
  }
}
