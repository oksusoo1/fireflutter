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
  String siNm = '';
  String sggNm = '';
  String job = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job List'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Text('''
@TODO:
Search with the combanation of: Company name, location(province), location(city), job category, working hours, working days of week, accommodations, salary,
'''),
          Divider(),
          Text('Job search options'),
          Divider(),
          Text(
            'Select location',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
          Wrap(
            children: [
              DropdownButton<String>(
                value: siNm,
                items: [
                  DropdownMenuItem(
                    child: Text('Select location'),
                    value: '',
                  ),
                  for (final name in JobService.instance.areas.keys)
                    DropdownMenuItem(
                      child: Text(name),
                      value: name,
                    )
                ],
                onChanged: (s) {
                  setState(
                    () {
                      if (siNm != s) {
                        sggNm = '';
                      }
                      siNm = s ?? '';
                    },
                  );
                },
              ),
              if (siNm != '')
                DropdownButton<String>(
                  value: sggNm,
                  items: [
                    DropdownMenuItem(
                      child: Text('Select city/county/gu'),
                      value: '',
                    ),
                    for (final name in JobService.instance.areas[siNm]!)
                      DropdownMenuItem(
                        child: Text(name),
                        value: name,
                      )
                  ],
                  onChanged: (s) {
                    setState(() {
                      sggNm = s ?? '';
                    });
                  },
                ),
              DropdownButton<String>(
                  value: job,
                  items: [
                    DropdownMenuItem(
                      child: Text('Select job category'),
                      value: '',
                    ),
                    ...JobService.instance.categories.entries
                        .map((e) => DropdownMenuItem(
                              child: Text(e.value),
                              value: e.key,
                            ))
                        .toList(),
                  ],
                  onChanged: (s) {
                    setState(() {
                      job = s ?? '';
                    });
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
