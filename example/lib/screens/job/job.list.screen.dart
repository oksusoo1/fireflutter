import 'package:fe/screens/forum/forum.mixin.dart';
import './job.edit.screen.dart';
import 'package:fe/service/app.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({required this.arguments, Key? key}) : super(key: key);
  static final String routeName = '/jobList';

  final Map arguments;

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen>
    with FirestoreMixin, ForumMixin {
  TextEditingController companyName = TextEditingController(text: '');
  String siNm = '';
  String sggNm = '';
  String jobCategory = '';
  int workingHours = -1;
  int workingDays = -1;
  String withAccomodation = '';
  String salary = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job List'),
      ),
      body: SingleChildScrollView(
        child: Column(
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
            Text(siNm +
                " " +
                sggNm +
                " " +
                jobCategory +
                " " +
                "${workingHours == 0 ? "flexible" : workingHours > 0 ? workingHours : ''} hour" +
                " " +
                "${workingDays == 0 ? "flexible" : workingDays > 0 ? workingDays : ''} day" +
                " " +
                "${withAccomodation == 'Y' ? 'with accomodation' : withAccomodation == 'N' ? "without accomodation" : ''}" +
                " " +
                salary +
                " salary"),
            Divider(),
            Text('Job search options'),
            Divider(),

            // Text(
            //   'Select location',
            //   style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
            // ),
            Wrap(
              children: [
                TextField(
                  controller: companyName,
                  decoration: InputDecoration(
                    labelText: "Company name",
                  ),
                ),
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
                  value: jobCategory,
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
                  onChanged: (v) {
                    setState(() {
                      jobCategory = v ?? '';
                    });
                  },
                ),
                DropdownButton<int>(
                    value: workingHours,
                    items: [
                      DropdownMenuItem(
                        child: Text('Select working housrs'),
                        value: -1,
                      ),
                      DropdownMenuItem(
                        child: Text('Flexible'),
                        value: 0,
                      ),
                      DropdownMenuItem(
                        child: Text('1 hour'),
                        value: 1,
                      ),
                      for (int i = 2; i <= 14; i++)
                        DropdownMenuItem(
                          child: Text('$i hours'),
                          value: i,
                        ),
                    ],
                    onChanged: (n) {
                      // print('s; $s');
                      setState(() {
                        workingHours = n ?? 0;
                      });
                    }),
                DropdownButton<int>(
                    value: workingDays,
                    items: [
                      DropdownMenuItem(
                        child: Text('Select working days'),
                        value: -1,
                      ),
                      DropdownMenuItem(
                        child: Text('Flexible'),
                        value: 0,
                      ),
                      DropdownMenuItem(
                        child: Text('1 day'),
                        value: 1,
                      ),
                      for (int i = 2; i <= 7; i++)
                        DropdownMenuItem(
                          child: Text('$i days'),
                          value: i,
                        ),
                    ],
                    onChanged: (n) {
                      // print('s; $s');
                      setState(() {
                        workingDays = n ?? 0;
                      });
                    }),
                DropdownButton<String>(
                    value: withAccomodation,
                    items: [
                      DropdownMenuItem(
                        child: Text('With Accomodation?'),
                        value: '',
                      ),
                      DropdownMenuItem(
                        child: Text('Yes'),
                        value: 'Y',
                      ),
                      DropdownMenuItem(
                        child: Text('No'),
                        value: "N",
                      ),
                    ],
                    onChanged: (n) {
                      // print('s; $s');
                      setState(() {
                        withAccomodation = n ?? '';
                      });
                    }),
                DropdownButton<String>(
                    value: salary,
                    items: [
                      DropdownMenuItem(
                        child: Text('Select salary'),
                        value: '',
                      ),
                      ...JobService.instance.salaries.map(
                        (s) => DropdownMenuItem(
                          child: Text("$s Won"),
                          value: s,
                        ),
                      )
                    ],
                    onChanged: (s) {
                      setState(() {
                        salary = s ?? "";
                      });
                    }),
                TextButton(
                    onPressed: () async {
                      print('search starts here');
                      // TextEditingController companyName = TextEditingController(text: '');
                      // String siNm = '';
                      // String sggNm = '';
                      // String jobCategory = '';
                      // int workingHours = -1;
                      // int workingDays = -1;
                      // String withAccomodation = '';
                      // String salary = '';
                      Query ref = postCol.where('createdAt',
                          isLessThanOrEqualTo: Timestamp.now());
                      if (companyName.text != '')
                        ref = ref.where('companyName',
                            isEqualTo: companyName.text);
                      if (siNm != '') ref = ref.where('siNm', isEqualTo: siNm);
                      if (sggNm != '')
                        ref = ref.where('sggNm', isEqualTo: sggNm);
                      if (jobCategory != '')
                        ref = ref.where('jobCategory', isEqualTo: jobCategory);
                      if (workingHours != -1)
                        ref =
                            ref.where('workingHours', isEqualTo: workingHours);
                      if (workingDays != -1)
                        ref = ref.where('workingDays', isEqualTo: workingDays);
                      if (withAccomodation != '')
                        ref = ref.where('withAccomodation',
                            isEqualTo: withAccomodation);
                      if (salary != '')
                        ref = ref.where('salary', isEqualTo: salary);
                      try {
                        final res = await ref.get();
                        print(res);
                      } catch (e) {
                        print('error query');
                        print(e);
                      }
                    },
                    child: Text("Search"))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
