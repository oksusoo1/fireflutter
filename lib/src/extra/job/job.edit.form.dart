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

class _JobEditFormState extends State<JobEditForm> {
  final companyName = TextEditingController(text: 'test company name');
  final phoneNumber = TextEditingController(text: 'test phone number');
  final mobileNumber = TextEditingController(text: 'text mobile number');
  final email = TextEditingController(text: 'test email');
  final jobCategory = TextEditingController();
  final detailAddress = TextEditingController(text: 'test detail address');
  final aboutUs = TextEditingController(text: 'test about us');
  final numberOfHiring = TextEditingController(text: '3');
  final jobDescription = TextEditingController(text: 'test job descriptiom');
  final requirement = TextEditingController(text: 'test requirement');
  final duty = TextEditingController(text: 'test duty');
  final salary = TextEditingController();
  final benefit = TextEditingController(text: 'test benefits');

  AddressModel? addr;

  String selected = '';
  int workingHours = 0;

  getAddress() async {
    addr = await JobService.instance.inputAddress(context);
    // print(addr);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Timer(Duration(milliseconds: 100), getAddress);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('''
@TODO
- Let company choose working hours of : 1hour, 2hour, 3hour, ... 14 hours.
- Let company choose working days in a week: 1 day, 2days, ... 7 days.
- Let company choose if they provide accommodations: Yes, No.
- Let comapny choose the salary: 100K Won, 200K Won, ... 4.5M Won.
/// '''),
        Text('Create a job opening'),
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
        GestureDetector(
          onTap: getAddress,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Address'),
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

        Text('Job category', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
        DropdownButton<String>(
            value: selected,
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
                selected = s ?? '';
                jobCategory.text = s ?? '';
              });
            }),

        TextField(
          controller: aboutUs,
          decoration: InputDecoration(
            labelText: "About us",
          ),
        ),
        TextField(
          controller: numberOfHiring,
          decoration: InputDecoration(
            labelText: "Number of hiring",
          ),
        ),

        Text('Working hours', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
        DropdownButton<int>(
            value: workingHours,
            items: [
              DropdownMenuItem(
                child: Text('Select working housrs'),
                value: 0,
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
          controller: salary,
          decoration: InputDecoration(
            labelText: "Salary",
          ),
        ),
        TextField(
          controller: benefit,
          decoration: InputDecoration(
            labelText: "benefits(free meals, dormitory, transporation, etc)",
          ),
        ),
        Divider(),

        /// daesung gimhae
        ElevatedButton(
          onPressed: () async {
            if (companyName.text == '') return widget.onError('Select company name');
            if (phoneNumber.text == '') return widget.onError('Select phone number');
            if (jobCategory.text == '') return widget.onError('Select job category');

            try {
              final extra = {
                'companyName': companyName.text,
                'phoneNumber': phoneNumber.text,
                'mobileNumber': mobileNumber.text,
                'email': email.text,
                'jobCategory': jobCategory.text,
                'workingHours': workingHours,
                'detailAddress': detailAddress.text,
                'aboutUs': aboutUs.text,
                'numberOfHiring': numberOfHiring.text,
                'jobDescription': jobDescription.text,
                'requirement': requirement.text,
                'duty': duty.text,
                'salary': salary.text,
                'benefit': benefit.text,
                'roadAddr': addr?.roadAddr ?? '',
                'korAddr': addr?.korAddr ?? '',
                'zipNo': addr?.zipNo ?? '',
                'siNm': addr?.siNm ?? '',
                'sggNm': addr?.sggNm ?? '',
                'emdNm': addr?.emdNm ?? '',
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
    );
  }
}
