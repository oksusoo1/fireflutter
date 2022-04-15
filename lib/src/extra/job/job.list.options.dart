import '../../../fireflutter.dart';
import 'package:flutter/material.dart';

class JobListOptions extends StatefulWidget {
  const JobListOptions({Key? key, required this.change}) : super(key: key);

  final Function(JobListOptionModel) change;

  @override
  State<JobListOptions> createState() => _JobListOptionsState();
}

class _JobListOptionsState extends State<JobListOptions> with FirestoreMixin {
  final options = JobListOptionModel();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Row(children: [
                Expanded(
                  child: TextField(
                    controller:
                        TextEditingController(text: options.companyName),
                    decoration: InputDecoration(
                      labelText: "Company name",
                    ),
                    onChanged: (v) {
                      bounce('companyName', 500, (_) async {
                        print('search via company name');
                        options.companyName = v;
                        widget.change(options);
                      });
                    },
                  ),
                ),
              ]),
              Row(
                children: [
                  DropdownButton<String>(
                    value: options.jobCategory,
                    items: [
                      DropdownMenuItem(
                        child: Text('Job category'),
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
                        options.jobCategory = v ?? '';
                      });
                      widget.change(options);
                    },
                  ),
                  DropdownButton<String>(
                      value: options.salary,
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
                          options.salary = s ?? "";
                        });

                        widget.change(options);
                      }),
                ],
              ),
              Row(
                children: [
                  DropdownButton<String>(
                    value: options.siNm,
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
                          if (options.siNm != s) {
                            options.sggNm = '';
                          }
                          options.siNm = s ?? '';
                        },
                      );

                      widget.change(options);
                    },
                  ),
                  if (options.siNm != '')
                    DropdownButton<String>(
                      value: options.sggNm,
                      items: [
                        DropdownMenuItem(
                          child: Text('Select city/county/gu'),
                          value: '',
                        ),
                        for (final name
                            in JobService.instance.areas[options.siNm]!)
                          DropdownMenuItem(
                            child: Text(name),
                            value: name,
                          )
                      ],
                      onChanged: (s) {
                        setState(() {
                          options.sggNm = s ?? '';
                        });

                        widget.change(options);
                      },
                    ),
                ],
              ),
              Row(
                children: [
                  DropdownButton<int>(
                      value: options.workingHours,
                      items: [
                        DropdownMenuItem(
                          child: Text('Working hours'),
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
                          options.workingHours = n ?? 0;
                        });

                        widget.change(options);
                      }),
                  DropdownButton<int>(
                      value: options.workingDays,
                      items: [
                        DropdownMenuItem(
                          child: Text('Working days'),
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
                          options.workingDays = n ?? 0;
                        });

                        widget.change(options);
                      }),
                  DropdownButton<String>(
                      value: options.accomodation,
                      items: [
                        DropdownMenuItem(
                          child: Text('Accomodation?'),
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
                          options.accomodation = n ?? '';
                        });

                        widget.change(options);
                      }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
