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
  Set<FormErrorCodes> errors = {};
  final Map<dynamic, dynamic> errorMessages = {
    FormErrorCodes.companyName.index: "*Please input company name.",
    FormErrorCodes.mobileNumber.index: "*Please input company mobile number.",
    FormErrorCodes.phoneNumber.index: "*Please input company office number.",
    FormErrorCodes.email.index: "*Please input company email address.",
    FormErrorCodes.aboutUs.index: "*Please tell something about your company.",
    FormErrorCodes.addr.index: "*Please select your company address.",
    FormErrorCodes.detailAddress.index: "*Please input a detailed address.",
    FormErrorCodes.jobCategory.index: "*Please select job category.",
    FormErrorCodes.numberOfHiring.index: "*Please input number of available slot for hiring.",
    FormErrorCodes.workingDays.index: "*Please select the number of days to work per week.",
    FormErrorCodes.workingHours.index: "*Please select the number of hours to work per day.",
    FormErrorCodes.salary.index: "*Please select a salary to offer.",
    FormErrorCodes.jobDescription.index: "*Please describe something about the job.",
    FormErrorCodes.requirement.index: "*Please enumerate the requirements for the job.",
    FormErrorCodes.duty.index: "*Please enumerate the duties of the job.",
    FormErrorCodes.benefit.index: "*Please enumerate the benefit given for the job.",
    FormErrorCodes.withAccomodation.index: "*Please select if the job includes an accomodation.",
  };

  getAddress() async {
    addr = await JobService.instance.inputAddress(context);
    if (addr != null) {
      errors.remove(FormErrorCodes.addr);
    } else {
      errors.add(FormErrorCodes.addr);
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Create a job opening'),

          Divider(height: 30, thickness: 2),
          Text('Company details', style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
          SizedBox(height: 15),

          /// Company name
          JobFormTextField(
            controller: companyName,
            label: "Company name",
            onUnfocus: () => validateTextField(companyName, FormErrorCodes.companyName),
            errorMessage: errorMessage(FormErrorCodes.companyName),
          ),

          /// Company mobile number
          JobFormTextField(
            controller: mobileNumber,
            keyboardType: TextInputType.phone,
            label: "Mobile phone number",
            onUnfocus: () => validateTextField(mobileNumber, FormErrorCodes.mobileNumber),
            errorMessage: errorMessage(FormErrorCodes.mobileNumber),
          ),

          /// Company phone number
          JobFormTextField(
            controller: phoneNumber,
            keyboardType: TextInputType.phone,
            label: "Office phone number",
            onUnfocus: () => validateTextField(phoneNumber, FormErrorCodes.phoneNumber),
            errorMessage: errorMessage(FormErrorCodes.phoneNumber),
          ),

          /// Company email
          JobFormTextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            label: "Email address",
            onUnfocus: () => validateTextField(email, FormErrorCodes.email),
            errorMessage: errorMessage(FormErrorCodes.email),
          ),

          /// Company about us
          JobFormTextField(
            controller: aboutUs,
            label: "About us",
            maxLines: 5,
            onUnfocus: () => validateTextField(aboutUs, FormErrorCodes.aboutUs),
            errorMessage: errorMessage(FormErrorCodes.aboutUs),
          ),

          /// Company address
          SizedBox(height: 8),
          GestureDetector(
            onTap: getAddress,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Address',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (addr == null)
                        Text('* Select your address.')
                      else
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('${addr?.roadAddr}'),
                            Text('${addr?.korAddr}'),
                          ]),
                        ),
                      Text('Select', style: TextStyle(fontSize: 14, color: Colors.blue)),
                    ],
                  ),
                  SizedBox(height: 5),
                  errorMessageWidget(FormErrorCodes.addr),
                ],
              ),
            ),
          ),

          /// Company detailed address
          if (addr != null) ...[
            JobFormTextField(
              controller: detailAddress,
              label: "Input detail address",
              maxLines: 2,
              onUnfocus: () => validateTextField(detailAddress, FormErrorCodes.detailAddress),
              errorMessage: errorMessage(FormErrorCodes.detailAddress),
            ),
          ],

          Divider(height: 30, thickness: 2),
          Text('Job Details', style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
          SizedBox(height: 20),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Job category
                Text('Job category', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
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
                      errors.remove(FormErrorCodes.jobCategory);
                    } else {
                      errors.add(FormErrorCodes.jobCategory);
                    }
                    setState(() {
                      jobCategory = s ?? '';
                    });
                  },
                ),
                errorMessageWidget(FormErrorCodes.jobCategory),

                /// Working days
                SizedBox(height: 8),
                Text(
                  'Working days per week',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
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
                      errors.remove(FormErrorCodes.workingDays);
                    } else {
                      errors.add(FormErrorCodes.workingDays);
                    }
                    setState(() {
                      workingDays = n ?? -1;
                    });
                  },
                ),
                errorMessageWidget(FormErrorCodes.workingDays),

                /// Working hours
                SizedBox(height: 8),
                Text(
                  'Working hour per day',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
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
                      errors.remove(FormErrorCodes.workingHours);
                    } else {
                      errors.add(FormErrorCodes.workingHours);
                    }
                    setState(() {
                      workingHours = n ?? -1;
                    });
                  },
                ),
                errorMessageWidget(FormErrorCodes.workingHours),

                /// Salary
                SizedBox(height: 8),
                Text('Salary', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
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
                      errors.remove(FormErrorCodes.salary);
                    } else {
                      errors.add(FormErrorCodes.salary);
                    }
                    setState(() {
                      salary = s ?? "";
                    });
                  },
                ),
                errorMessageWidget(FormErrorCodes.salary),
              ],
            ),
          ),

          /// Job number of hiring
          JobFormTextField(
            controller: numberOfHiring,
            keyboardType: TextInputType.number,
            label: "Number of hiring",
            onUnfocus: () => validateTextField(numberOfHiring, FormErrorCodes.numberOfHiring),
            errorMessage: errorMessage(FormErrorCodes.numberOfHiring),
          ),

          /// Job description
          JobFormTextField(
            controller: jobDescription,
            label: "Job description(details of what workers will do)",
            maxLines: 3,
            onUnfocus: () => validateTextField(jobDescription, FormErrorCodes.jobDescription),
            errorMessage: errorMessage(FormErrorCodes.jobDescription),
          ),

          /// requirements
          JobFormTextField(
            controller: requirement,
            label: "Requirements and qualifications",
            maxLines: 5,
            onUnfocus: () => validateTextField(requirement, FormErrorCodes.requirement),
            errorMessage: errorMessage(
              FormErrorCodes.requirement,
            ),
          ),

          /// duty
          JobFormTextField(
            controller: duty,
            label: "Duties and responsibilities",
            maxLines: 5,
            onUnfocus: () => validateTextField(duty, FormErrorCodes.duty),
            errorMessage: errorMessage(FormErrorCodes.duty),
          ),

          /// benefit
          JobFormTextField(
            controller: benefit,
            label: "benefits(free meals, dormitory, transporation, etc)",
            maxLines: 5,
            onUnfocus: () => validateTextField(benefit, FormErrorCodes.benefit),
            errorMessage: errorMessage(FormErrorCodes.benefit),
          ),

          SizedBox(height: 8),

          /// Accomodation
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Includes accomodation?',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                SizedBox(height: 5),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ListTile(
                        dense: true,
                        title: const Text('Yes'),
                        leading: Radio<String>(
                          value: "Y",
                          groupValue: withAccomodation,
                          onChanged: (v) => updateAccomodation(v!),
                        ),
                        onTap: () => updateAccomodation("Y"),
                        selected: withAccomodation == "Y",
                        selectedTileColor: Colors.yellow.shade100,
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        dense: true,
                        title: const Text('No'),
                        leading: Radio<String>(
                          value: 'N',
                          groupValue: withAccomodation,
                          onChanged: (v) => updateAccomodation(v!),
                        ),
                        onTap: () => updateAccomodation("N"),
                        selected: withAccomodation == "N",
                        selectedTileColor: Colors.yellow.shade100,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                errorMessageWidget(FormErrorCodes.withAccomodation),
              ],
            ),
          ),

          Divider(),

          // for (final errCode in errors) Text('${errorMessages[errCode.index]}'),

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
    errors.remove(FormErrorCodes.withAccomodation);
    setState(() => withAccomodation = yN);
  }

  /// checks if there is an error on the form. Or required data is not complete.
  bool checkHasError() {
    setState(errors.clear);
    if (companyName.text == '') errors.add(FormErrorCodes.companyName);
    if (mobileNumber.text == '') errors.add(FormErrorCodes.mobileNumber);
    if (phoneNumber.text == '') errors.add(FormErrorCodes.phoneNumber);
    if (email.text == '') errors.add(FormErrorCodes.email);

    if (addr == null) errors.add(FormErrorCodes.addr);
    if (detailAddress.text == '') errors.add(FormErrorCodes.detailAddress);
    if (aboutUs.text == '') errors.add(FormErrorCodes.aboutUs);

    if (jobDescription.text == '') errors.add(FormErrorCodes.jobDescription);
    if (requirement.text == '') errors.add(FormErrorCodes.requirement);
    if (duty.text == '') errors.add(FormErrorCodes.duty);
    if (benefit.text == '') errors.add(FormErrorCodes.benefit);
    if (jobCategory == '') errors.add(FormErrorCodes.jobCategory);
    if (salary == '') errors.add(FormErrorCodes.salary);
    if (numberOfHiring.text == '') errors.add(FormErrorCodes.numberOfHiring);

    if (workingDays == -1) errors.add(FormErrorCodes.workingDays);
    if (workingHours == -1) errors.add(FormErrorCodes.workingHours);
    if (withAccomodation == '') errors.add(FormErrorCodes.withAccomodation);
    setState(() {});
    return errors.isNotEmpty;
  }

  /// Returns a widget if the given code have an error.
  String? errorMessage(FormErrorCodes code) {
    if (isSubmitted && errors.contains(code)) {
      return errorMessages[code.index];
    }
    return null;
  }

  /// Returns error text widget
  Widget errorMessageWidget(FormErrorCodes code) {
    final String? error = errorMessage(code);
    if (error != null) {
      return Text(
        '$error',
        style: TextStyle(
          fontSize: 12,
          color: Colors.red,
          fontStyle: FontStyle.italic,
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  /// Text field validator
  ///
  validateTextField(TextEditingController controller, FormErrorCodes code) {
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
    required this.errorMessage,
    this.keyboardType,
    this.maxLines,
    Key? key,
  }) : super(key: key);

  final TextEditingController controller;
  final String label;
  final Function() onUnfocus;
  final TextInputType? keyboardType;
  final String? errorMessage;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Focus(
        onFocusChange: (b) {
          if (!b) onUnfocus();
        },
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          minLines: maxLines != null ? 1 : null,
          maxLines: maxLines,
          decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
              errorText: errorMessage,
              errorStyle: TextStyle(fontStyle: FontStyle.italic)),
        ),
      ),
    );
  }
}
