import 'package:flutter/material.dart';

import '../../../fireflutter.dart';

/// 직업 입력 양식
///
///
///
class JobEditForm extends StatefulWidget {
  const JobEditForm({
    Key? key,
    required this.onError,
  }) : super(key: key);

  final Function onError;

  @override
  State<JobEditForm> createState() => _JobEditFormState();
}

// - Let company choose working hours of : 1hour, 2hour, 3hour, ... 14 hours.
// - Let company choose working days in a week: 1 day, 2days, ... 7 days.
// - Let company choose if they provide accommodations: Yes, No.
// - Let comapny choose the salary: 100K Won, 200K Won, ... 4.5M Won.
class _JobEditFormState extends State<JobEditForm> {
  final companyName = TextEditingController(text: 'test company name');
  final phoneNumber = TextEditingController(text: 'test phone number');
  final mobileNumber = TextEditingController(text: 'text mobile number');
  final email = TextEditingController(text: 'test email');
  final detailAddress = TextEditingController(text: 'test detail address');
  final aboutUs = TextEditingController(text: 'test about us');
  final numberOfHiring = TextEditingController(text: '3');
  final jobDescription = TextEditingController(text: 'test job descriptiom');
  final requirement = TextEditingController(text: 'test requirement');
  final duty = TextEditingController(text: 'test duty');
  final benefit = TextEditingController(text: 'test benefits');

  AddressModel? addr;

  String jobCategory = '';
  String salary = '';

  /// -1 means that the user didn't select working days.
  int workingDays = -1;

  /// -1 means that the user didn't select working hours.
  int workingHours = -1;
  String withAccomodation = '';

  getAddress() async {
    addr = await JobService.instance.inputAddress(context);
    // print(addr);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Timer(Duration(milliseconds: 100), getAddress);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Create a job opening'),

          Divider(height: 30, thickness: 2),
          Text('Company details', style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
          SizedBox(height: 15),
          TextField(
            controller: companyName,
            decoration: InputDecoration(
              labelText: "Company name",
            ),
          ),
          TextField(
            controller: mobileNumber,
            decoration: InputDecoration(
              labelText: "Mobile phone number",
            ),
          ),
          TextField(
            controller: phoneNumber,
            decoration: InputDecoration(
              labelText: "Office phone number",
            ),
          ),
          TextField(
            controller: email,
            decoration: InputDecoration(
              labelText: "Email address",
            ),
          ),
          TextField(
            controller: aboutUs,
            decoration: InputDecoration(
              labelText: "About us",
            ),
          ),

          SizedBox(height: 8),
          GestureDetector(
            onTap: getAddress,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Address', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                  if (addr == null)
                    Text('* Select your address.')
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${addr?.roadAddr}'),
                        Text('${addr?.korAddr}'),
                      ],
                    ),
                  Row(
                    children: [
                      Spacer(),
                      Text(
                        'Select',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          if (addr != null)
            TextField(
              controller: detailAddress,
              decoration: InputDecoration(
                labelText: "Input detail address",
              ),
            ),

          Divider(height: 30, thickness: 2),
          Text('Job Details', style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
          SizedBox(height: 20),
          Text('Job category', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
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
              onChanged: (s) {
                // print('s; $s');
                setState(() {
                  jobCategory = s ?? '';
                });
              }),

          TextField(
            controller: numberOfHiring,
            decoration: InputDecoration(
              labelText: "Number of hiring",
            ),
          ),

          /// Working days
          Text('Working days per week',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
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

          /// Working hours
          SizedBox(height: 8),
          Text('Working hour per day', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
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

          /// Salary
          Text('Salary', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
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

          TextField(
            controller: jobDescription,
            decoration: InputDecoration(
              labelText: "Job description(details of what workers will do)",
            ),
          ),
          TextField(
            controller: requirement,
            decoration: InputDecoration(
              labelText: "Requirements and qualifications",
            ),
          ),
          TextField(
            controller: duty,
            decoration: InputDecoration(
              labelText: "Duties and responsibilities",
            ),
          ),
          TextField(
            controller: benefit,
            decoration: InputDecoration(
              labelText: "benefits(free meals, dormitory, transporation, etc)",
            ),
          ),

          SizedBox(height: 8),

          /// Accomodation
          Text('With accomodation', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
          Wrap(
            children: <Widget>[
              ListTile(
                dense: true,
                title: const Text('Yes'),
                leading: Radio<String>(
                  value: "Y",
                  groupValue: withAccomodation,
                  onChanged: (v) => updateAccomodation(v!),
                ),
                onTap: () => updateAccomodation("Y"),
              ),
              ListTile(
                dense: true,
                title: const Text('No'),
                leading: Radio<String>(
                  value: 'N',
                  groupValue: withAccomodation,
                  onChanged: (v) => updateAccomodation(v!),
                ),
                onTap: () => updateAccomodation("N"),
              ),
            ],
          ),
          Divider(),

          /// daesung gimhae
          ElevatedButton(
            onPressed: () async {
              final error = hasError();
              if (error.length > 0) return widget.onError(error);

              try {
                final extra = {
                  'companyName': companyName.text,
                  'phoneNumber': phoneNumber.text,
                  'mobileNumber': mobileNumber.text,
                  'email': email.text,
                  'detailAddress': detailAddress.text,
                  'aboutUs': aboutUs.text,
                  'numberOfHiring': numberOfHiring.text,
                  'jobDescription': jobDescription.text,
                  'requirement': requirement.text,
                  'duty': duty.text,
                  'benefit': benefit.text,
                  'roadAddr': addr?.roadAddr ?? '',
                  'korAddr': addr?.korAddr ?? '',
                  'zipNo': addr?.zipNo ?? '',
                  'siNm': addr?.siNm ?? '',
                  'sggNm': addr?.sggNm ?? '',
                  'emdNm': addr?.emdNm ?? '',
                  'jobCategory': jobCategory,
                  'salary': salary,
                  'workingDays': workingDays,
                  'workingHours': workingHours,
                  'withAccomodation': withAccomodation,
                };
                print(extra);

                /// For indexing and listing in normal forum.
                String title = "";
                String content = "";

                await PostApi.instance.create(
                  category: JobService.instance.jobOpenings,
                  title: title,
                  content: content,
                  extra: extra,
                );
              } catch (e, stacks) {
                debugPrintStack(stackTrace: stacks);
                widget.onError(e);
              }
            },
            child: Text('Submit'),
          )
        ],
      ),
    );
  }

  void updateAccomodation(String yN) {
    setState(() => withAccomodation = yN);
  }

  /// checks if there is an error on the form. Or required data is not complete.
  String hasError() {
    /// TODO: add more required data error (if necessary).
    if (companyName.text == '') return 'Input company name';
    if (phoneNumber.text == '') return 'Input phone number';
    if (jobCategory == '') return 'Select job category';
    if (salary == '') return 'Select job salary';
    if (workingDays == -1) return 'Select working days';
    if (workingHours == -1) return 'Select working hours';
    if (withAccomodation == '') return 'Select accomodation availability';
    return '';
  }
}
