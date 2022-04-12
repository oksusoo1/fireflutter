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
  final companyName = TextEditingController();
  final phoneNumber = TextEditingController();
  final mobileNumber = TextEditingController();
  final email = TextEditingController();
  final jobCategory = TextEditingController();
  final workingHours = TextEditingController();
  final detailAddress = TextEditingController();
  final aboutUs = TextEditingController();
  final numberOfHiring = TextEditingController();
  final jobDescription = TextEditingController();
  final requirement = TextEditingController();
  final duty = TextEditingController();
  final salary = TextEditingController();
  final benefit = TextEditingController();

  AddressModel? addr;

  String selected = '';

  getAddress() async {
    addr = await JobService.instance.inputAddress(context);
    print(addr);
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
        // TextField(
        //   controller: jobCategory,
        //   decoration: InputDecoration(
        //     labelText: "Job category(industry) - @todo select box",
        //   ),
        // ),

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
              print('s; $s');
              setState(() {
                selected = s ?? '';
                jobCategory.text = s ?? '';
              });
            }),
        // Select(
        //   defaultLabel: "Select job category",
        //   options: JobService.instance.categories,
        //   onChanged: (v) {
        //     print(v);
        //   },
        // ),
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
        TextField(
          controller: workingHours,
          decoration: InputDecoration(
            labelText: "Working hours",
          ),
        ),
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
            try {
              final extra = {
                'companyName': companyName.text,
                'phoneNumber': phoneNumber.text,
                'mobileNumber': mobileNumber.text,
                'email': email.text,
                'jobCategory': jobCategory.text,
                'workingHours': workingHours.text,
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
              // await PostApi.instance.create(category: 'job_openings', extra: extra);
            } catch (e) {
              widget.onError(e);
            }
          },
          child: Text('Submit'),
        )
      ],
    );
  }
}
