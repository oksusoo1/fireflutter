import 'package:flutter/material.dart';

import '../../../fireflutter.dart';

enum JobFormErrorCode {
  companyName,
  mobileNumber,
  phoneNumber,
  email,
  addr,
  detailAddress,
  aboutUs,
  numberOfHiring,
  jobDescription,
  requirement,
  duty,
  benefit,
  jobCategory,
  salary,
  workingDays,
  workingHours,
  withAccomodation
}

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
  final companyName = TextEditingController(text: '');
  final phoneNumber = TextEditingController(text: '');
  final mobileNumber = TextEditingController(text: '');
  final email = TextEditingController(text: '');
  final detailAddress = TextEditingController(text: '');
  final aboutUs = TextEditingController(text: '');
  final numberOfHiring = TextEditingController(text: '');
  final jobDescription = TextEditingController(text: '');
  final requirement = TextEditingController(text: '');
  final duty = TextEditingController(text: '');
  final benefit = TextEditingController(text: '');

  AddressModel? addr;

  String jobCategory = '';
  String salary = '';

  /// -1 means that the user didn't select working days.
  int workingDays = -1;

  /// -1 means that the user didn't select working hours.
  int workingHours = -1;
  String withAccomodation = '';

  bool isSubmitted = false;
  Set<JobFormErrorCode> errors = {};

  getAddress() async {
    addr = await JobService.instance.inputAddress(context);
    if (addr != null) {
      errors.remove(JobFormErrorCode.addr);
    } else {
      errors.add(JobFormErrorCode.addr);
    }
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

          /// Company name
          JobFormTextField(
            controller: companyName,
            label: "Company name",
            onUnfocus: () => validateTextField(companyName, JobFormErrorCode.companyName),
          ),
          errorMessage(JobFormErrorCode.companyName, "Please input company name."),

          /// Company mobile number
          JobFormTextField(
            controller: mobileNumber,
            keyboardType: TextInputType.phone,
            label: "Mobile phone number",
            onUnfocus: () => validateTextField(mobileNumber, JobFormErrorCode.mobileNumber),
          ),
          errorMessage(JobFormErrorCode.mobileNumber, "Please input company mobile number."),

          /// Company phone number
          JobFormTextField(
            controller: phoneNumber,
            keyboardType: TextInputType.phone,
            label: "Office phone number",
            onUnfocus: () => validateTextField(phoneNumber, JobFormErrorCode.phoneNumber),
          ),
          errorMessage(JobFormErrorCode.phoneNumber, "Please input company office number."),

          /// Company email
          JobFormTextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            label: "Email address",
            onUnfocus: () => validateTextField(email, JobFormErrorCode.email),
          ),
          errorMessage(JobFormErrorCode.email, "Please input company email address."),

          /// Company about us
          JobFormTextField(
            controller: aboutUs,
            label: "About us",
            onUnfocus: () => validateTextField(aboutUs, JobFormErrorCode.aboutUs),
          ),
          errorMessage(JobFormErrorCode.aboutUs, "Please tell something about your company."),

          /// Company address
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
          errorMessage(JobFormErrorCode.addr, "Please select your company address."),

          /// Company detailed address
          if (addr != null) ...[
            JobFormTextField(
              controller: detailAddress,
              label: "Input detail address",
              onUnfocus: () => validateTextField(detailAddress, JobFormErrorCode.detailAddress),
            ),
            errorMessage(JobFormErrorCode.detailAddress, "Please input a detailed address."),
          ],

          Divider(height: 30, thickness: 2),
          Text('Job Details', style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
          SizedBox(height: 20),

          /// Job category
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
              if (s != null && s.isNotEmpty) {
                errors.remove(JobFormErrorCode.jobCategory);
              } else {
                errors.add(JobFormErrorCode.jobCategory);
              }
              setState(() {
                jobCategory = s ?? '';
              });
            },
          ),
          errorMessage(JobFormErrorCode.jobCategory, "Please select job category."),

          /// Job number of hiring
          JobFormTextField(
            controller: numberOfHiring,
            keyboardType: TextInputType.number,
            label: "Number of hiring",
            onUnfocus: () => validateTextField(numberOfHiring, JobFormErrorCode.numberOfHiring),
          ),
          errorMessage(
            JobFormErrorCode.numberOfHiring,
            "Please input number of available slot for hiring.",
          ),

          /// Working days
          Text(
            'Working days per week',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
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
              if (n != null && n > -1) {
                errors.remove(JobFormErrorCode.workingDays);
              } else {
                errors.add(JobFormErrorCode.workingDays);
              }
              setState(() {
                workingDays = n ?? -1;
              });
            },
          ),
          errorMessage(
            JobFormErrorCode.workingDays,
            "Please select the number of days to work per week.",
          ),

          /// Working hours
          SizedBox(height: 8),
          Text('Working hour per day', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
          DropdownButton<int>(
            value: workingHours,
            items: [
              DropdownMenuItem(
                child: Text('Select working hours'),
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
              if (n != null && n > -1) {
                errors.remove(JobFormErrorCode.workingHours);
              } else {
                errors.add(JobFormErrorCode.workingHours);
              }
              setState(() {
                workingHours = n ?? -1;
              });
            },
          ),
          errorMessage(
            JobFormErrorCode.workingHours,
            "Please select the number of hours to work per day.",
          ),

          /// Salary
          SizedBox(height: 8),
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
              if (s != null && s.isNotEmpty) {
                errors.remove(JobFormErrorCode.salary);
              } else {
                errors.add(JobFormErrorCode.salary);
              }
              setState(() {
                salary = s ?? "";
              });
            },
          ),
          errorMessage(JobFormErrorCode.salary, "Please select a salary to offer."),

          /// Job description
          JobFormTextField(
            controller: jobDescription,
            label: "Job description(details of what workers will do)",
            onUnfocus: () => validateTextField(jobDescription, JobFormErrorCode.jobDescription),
          ),
          errorMessage(JobFormErrorCode.jobDescription, "Please describe something about the job."),

          /// requirements
          JobFormTextField(
            controller: requirement,
            label: "Requirements and qualifications",
            onUnfocus: () => validateTextField(requirement, JobFormErrorCode.requirement),
          ),
          errorMessage(
            JobFormErrorCode.requirement,
            "Please enumerate the requirements for the job.",
          ),

          /// duty
          JobFormTextField(
            controller: duty,
            label: "Duties and responsibilities",
            onUnfocus: () => validateTextField(duty, JobFormErrorCode.duty),
          ),
          errorMessage(JobFormErrorCode.duty, "Please enumerate the duties of the job"),

          /// benefit
          JobFormTextField(
            controller: benefit,
            label: "benefits(free meals, dormitory, transporation, etc)",
            onUnfocus: () => validateTextField(benefit, JobFormErrorCode.benefit),
          ),
          errorMessage(JobFormErrorCode.benefit, "Please enumerate the benefit given for the job."),

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
          errorMessage(
            JobFormErrorCode.withAccomodation,
            "Please select if the job includes an accomodation.",
          ),

          Divider(),

          /// daesung gimhae
          ElevatedButton(
            onPressed: () async {
              setState(() => isSubmitted = true);
              final hasErr = checkHasError();
              if (hasErr) {
                return widget.onError("Form data is incomplete, please check for errors.");
              }

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

                /// TODO: For indexing and listing in normal forum.
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
    errors.remove(JobFormErrorCode.withAccomodation);
    setState(() => withAccomodation = yN);
  }

  /// checks if there is an error on the form. Or required data is not complete.
  bool checkHasError() {
    setState(errors.clear);
    if (companyName.text == '') errors.add(JobFormErrorCode.companyName);
    if (mobileNumber.text == '') errors.add(JobFormErrorCode.mobileNumber);
    if (phoneNumber.text == '') errors.add(JobFormErrorCode.phoneNumber);
    if (email.text == '') errors.add(JobFormErrorCode.email);

    if (addr == null) errors.add(JobFormErrorCode.addr);
    if (detailAddress.text == '') errors.add(JobFormErrorCode.detailAddress);
    if (aboutUs.text == '') errors.add(JobFormErrorCode.aboutUs);

    if (numberOfHiring.text == '') errors.add(JobFormErrorCode.numberOfHiring);
    if (jobDescription.text == '') errors.add(JobFormErrorCode.jobDescription);
    if (requirement.text == '') errors.add(JobFormErrorCode.requirement);
    if (duty.text == '') errors.add(JobFormErrorCode.duty);
    if (benefit.text == '') errors.add(JobFormErrorCode.benefit);

    if (jobCategory == '') errors.add(JobFormErrorCode.jobCategory);
    if (salary == '') errors.add(JobFormErrorCode.salary);
    if (workingDays == -1) errors.add(JobFormErrorCode.workingDays);
    if (workingHours == -1) errors.add(JobFormErrorCode.workingHours);
    if (withAccomodation == '') errors.add(JobFormErrorCode.withAccomodation);
    setState(() {});
    return errors.isNotEmpty;
  }

  /// returns a widget if the given code have an error.
  Widget errorMessage(JobFormErrorCode code, String message) {
    if (isSubmitted && errors.contains(code)) {
      return Text(
        '* $message',
        style: TextStyle(
          fontSize: 14,
          color: Colors.red,
          fontStyle: FontStyle.italic,
        ),
      );
    }
    return SizedBox.shrink();
  }

  validateTextField(TextEditingController controller, JobFormErrorCode code) {
    if (controller.text == '') {
      errors.add(code);
    } else {
      errors.remove(code);
    }
    setState(() {});
  }
}

class JobFormTextField extends StatelessWidget {
  JobFormTextField({
    required this.controller,
    required this.label,
    required this.onUnfocus,
    this.keyboardType,
    Key? key,
  }) : super(key: key);

  final TextEditingController controller;
  final String label;
  final Function() onUnfocus;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (b) {
        if (!b) onUnfocus();
      },
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
        ),
      ),
    );
  }
}
