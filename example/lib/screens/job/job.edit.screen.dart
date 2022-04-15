import 'package:extended/extended.dart';
import 'package:fe/service/app.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class JobEditScreen extends StatefulWidget {
  const JobEditScreen({required this.arguments, Key? key}) : super(key: key);
  static final String routeName = '/jobEdit';

  final Map arguments;

  @override
  State<JobEditScreen> createState() => _JobEditScreenState();
}

class _JobEditScreenState extends State<JobEditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Edit'),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            JobEditForm(
              onError: error,
              onCreated: () async {
                await alert('Job create', 'Job opening created!');
                AppService.instance.back();
              },
              onUpdated: () async {
                await alert('Job updated', 'Job opening updated!');
                AppService.instance.back();
              },
              job: widget.arguments['job'],
            ),
            space2xl,
          ],
        ),
      )),
    );
  }
}
