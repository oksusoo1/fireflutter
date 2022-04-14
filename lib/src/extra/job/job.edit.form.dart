import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import '../../../fireflutter.dart';

/// Job posting form
///
///
class JobEditForm extends StatefulWidget {
  const JobEditForm({
    Key? key,
    required this.onCreated,
    required this.onUpdated,
    required this.onError,
    this.job,
  }) : super(key: key);

  final Function(String) onCreated;
  final Function(String) onUpdated;
  final Function(dynamic) onError;

  final JobModel? job;

  @override
  State<JobEditForm> createState() => _JobEditFormState();
}

class _JobEditFormState extends State<JobEditForm> {
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  /// TODO - what is this for?
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

  double uploadProgress = 0;
  bool get uploadLimited => job.files.length >= 5;

  bool get isCreate {
    return widget.job == null;
  }

  bool get isUpdate => !isCreate;

  JobModel job = JobModel.empty();

  @override
  initState() {
    super.initState();
    init();
  }

  init() {
    if (isUpdate) {
      job = widget.job!;
    }
  }

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
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Create a job opening'),

          Divider(height: 30, thickness: 2),
          Text('Company details', style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
          SizedBox(height: 15),

          TextFormField(
            initialValue: job.companyName,
            onChanged: (s) => job.companyName = s,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) => v == null || v == '' ? 'Input company name' : null,
            decoration: InputDecoration(labelText: 'Company name'),
          ),

          TextFormField(
            initialValue: job.mobileNumber,
            onChanged: (s) => job.mobileNumber = s,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) => v == null || v == '' ? 'Input mobile number' : null,
            decoration: InputDecoration(labelText: 'Mobile number'),
            keyboardType: TextInputType.phone,
          ),

          TextFormField(
            initialValue: job.phoneNumber,
            onChanged: (s) => job.phoneNumber = s,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) => v == null || v == '' ? 'Input office phone number' : null,
            decoration: InputDecoration(labelText: 'Office phone number number'),
            keyboardType: TextInputType.phone,
          ),

          TextFormField(
            initialValue: job.email,
            onChanged: (s) => job.email = s,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) =>
                EmailValidator.validate(v ?? '') ? null : 'Input correct email address',
            decoration: InputDecoration(labelText: 'Email'),
          ),

          // /// Company email
          // ///
          // JobEditFormTextField(
          //   controller: email,
          //   keyboardType: TextInputType.emailAddress,
          //   label: "Email address",
          //   onUnfocus: () => validateTextFieldForEmail(email, FormErrorCodes.email),
          //   errorMessage: errorMessage(FormErrorCodes.email),
          // ),

          // /// Company about us
          // JobEditFormTextField(
          //   controller: aboutUs,
          //   label: "About us",
          //   maxLines: 5,
          //   onUnfocus: () => validateTextField(aboutUs, FormErrorCodes.aboutUs),
          //   errorMessage: errorMessage(FormErrorCodes.aboutUs),
          // ),

          // /// Company address
          // SizedBox(height: 8),
          // GestureDetector(
          //   onTap: getAddress,
          //   behavior: HitTestBehavior.opaque,
          //   child: Container(
          //     width: double.infinity,
          //     margin: EdgeInsets.all(8),
          //     padding: EdgeInsets.all(8),
          //     decoration: BoxDecoration(
          //       border: Border.all(color: Colors.grey),
          //       borderRadius: BorderRadius.circular(6),
          //     ),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text(
          //           'Address',
          //           style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          //         ),
          //         SizedBox(height: 5),
          //         Row(
          //           mainAxisSize: MainAxisSize.max,
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             if (addr == null)
          //               Text('* Select your address.')
          //             else
          //               Expanded(
          //                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          //                   Text('${addr?.roadAddr}'),
          //                   Text('${addr?.korAddr}'),
          //                 ]),
          //               ),
          //             Text('Select', style: TextStyle(fontSize: 14, color: Colors.blue)),
          //           ],
          //         ),
          //         SizedBox(height: 5),
          //         errorMessageWidget(FormErrorCodes.addr),
          //       ],
          //     ),
          //   ),
          // ),

          // /// Company detailed address
          // if (addr != null) ...[
          //   JobEditFormTextField(
          //     controller: detailAddress,
          //     label: "Input detail address",
          //     maxLines: 2,
          //     onUnfocus: () => validateTextField(detailAddress, FormErrorCodes.detailAddress),
          //     errorMessage: errorMessage(FormErrorCodes.detailAddress),
          //   ),
          // ],

          // Divider(height: 30, thickness: 2),
          // Text('Job Details', style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
          // SizedBox(height: 20),

          // Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 8),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       /// Job category
          //       Text('Job category', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
          //       DropdownButton<String>(
          //         value: jobCategory,
          //         items: [
          //           DropdownMenuItem(
          //             child: Text('Select job category'),
          //             value: '',
          //           ),
          //           ...JobService.instance.categories.entries
          //               .map((e) => DropdownMenuItem(
          //                     child: Text(e.value),
          //                     value: e.key,
          //                   ))
          //               .toList(),
          //         ],
          //         onChanged: (s) {
          //           if (s != null && s.isNotEmpty) {
          //             errors.remove(FormErrorCodes.jobCategory);
          //           } else {
          //             errors.add(FormErrorCodes.jobCategory);
          //           }
          //           setState(() {
          //             jobCategory = s ?? '';
          //           });
          //         },
          //       ),
          //       errorMessageWidget(FormErrorCodes.jobCategory),

          //       /// Working days
          //       SizedBox(height: 8),
          //       Text(
          //         'Working days per week',
          //         style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          //       ),
          //       DropdownButton<int>(
          //         value: workingDays,
          //         items: [
          //           DropdownMenuItem(
          //             child: Text('Select working days'),
          //             value: -1,
          //           ),
          //           DropdownMenuItem(
          //             child: Text('Flexible'),
          //             value: 0,
          //           ),
          //           DropdownMenuItem(
          //             child: Text('1 day'),
          //             value: 1,
          //           ),
          //           for (int i = 2; i <= 7; i++)
          //             DropdownMenuItem(
          //               child: Text('$i days'),
          //               value: i,
          //             ),
          //         ],
          //         onChanged: (n) {
          //           if (n != null && n > -1) {
          //             errors.remove(FormErrorCodes.workingDays);
          //           } else {
          //             errors.add(FormErrorCodes.workingDays);
          //           }
          //           setState(() {
          //             workingDays = n ?? -1;
          //           });
          //         },
          //       ),
          //       errorMessageWidget(FormErrorCodes.workingDays),

          //       /// Working hours
          //       SizedBox(height: 8),
          //       Text(
          //         'Working hour per day',
          //         style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          //       ),
          //       DropdownButton<int>(
          //         value: workingHours,
          //         items: [
          //           DropdownMenuItem(
          //             child: Text('Select working hours'),
          //             value: -1,
          //           ),
          //           DropdownMenuItem(
          //             child: Text('Flexible'),
          //             value: 0,
          //           ),
          //           DropdownMenuItem(
          //             child: Text('1 hour'),
          //             value: 1,
          //           ),
          //           for (int i = 2; i <= 14; i++)
          //             DropdownMenuItem(
          //               child: Text('$i hours'),
          //               value: i,
          //             ),
          //         ],
          //         onChanged: (n) {
          //           if (n != null && n > -1) {
          //             errors.remove(FormErrorCodes.workingHours);
          //           } else {
          //             errors.add(FormErrorCodes.workingHours);
          //           }
          //           setState(() {
          //             workingHours = n ?? -1;
          //           });
          //         },
          //       ),
          //       errorMessageWidget(FormErrorCodes.workingHours),

          //       /// Salary
          //       SizedBox(height: 8),
          //       Text('Salary', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
          //       DropdownButton<String>(
          //         value: salary,
          //         items: [
          //           DropdownMenuItem(
          //             child: Text('Select salary'),
          //             value: '',
          //           ),
          //           ...JobService.instance.salaries.map(
          //             (s) => DropdownMenuItem(
          //               child: Text("$s Won"),
          //               value: s,
          //             ),
          //           )
          //         ],
          //         onChanged: (s) {
          //           if (s != null && s.isNotEmpty) {
          //             errors.remove(FormErrorCodes.salary);
          //           } else {
          //             errors.add(FormErrorCodes.salary);
          //           }
          //           setState(() {
          //             salary = s ?? "";
          //           });
          //         },
          //       ),
          //       errorMessageWidget(FormErrorCodes.salary),
          //     ],
          //   ),
          // ),

          // /// Job number of hiring
          // JobEditFormTextField(
          //   controller: numberOfHiring,
          //   keyboardType: TextInputType.number,
          //   label: "Number of hiring",
          //   onUnfocus: () => validateTextField(numberOfHiring, FormErrorCodes.numberOfHiring),
          //   errorMessage: errorMessage(FormErrorCodes.numberOfHiring),
          // ),

          // /// Job description
          // JobEditFormTextField(
          //   controller: jobDescription,
          //   label: "Job description(details of what workers will do)",
          //   maxLines: 3,
          //   onUnfocus: () => validateTextField(jobDescription, FormErrorCodes.jobDescription),
          //   errorMessage: errorMessage(FormErrorCodes.jobDescription),
          // ),

          // /// requirements
          // JobEditFormTextField(
          //   controller: requirement,
          //   label: "Requirements and qualifications",
          //   maxLines: 5,
          //   onUnfocus: () => validateTextField(requirement, FormErrorCodes.requirement),
          //   errorMessage: errorMessage(
          //     FormErrorCodes.requirement,
          //   ),
          // ),

          // /// duty
          // JobEditFormTextField(
          //   controller: duty,
          //   label: "Duties and responsibilities",
          //   maxLines: 5,
          //   onUnfocus: () => validateTextField(duty, FormErrorCodes.duty),
          //   errorMessage: errorMessage(FormErrorCodes.duty),
          // ),

          // /// benefit
          // JobEditFormTextField(
          //   controller: benefit,
          //   label: "benefits(free meals, dormitory, transporation, etc)",
          //   maxLines: 5,
          //   onUnfocus: () => validateTextField(benefit, FormErrorCodes.benefit),
          //   errorMessage: errorMessage(FormErrorCodes.benefit),
          // ),

          // SizedBox(height: 8),

          // Container(
          //   margin: EdgeInsets.symmetric(horizontal: 8),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       /// Accomodation
          //       Text(
          //         'Includes accomodation?',
          //         style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          //       ),
          //       SizedBox(height: 5),
          //       Row(
          //         children: <Widget>[
          //           Expanded(
          //             child: ListTile(
          //               dense: true,
          //               title: const Text('Yes'),
          //               leading: Radio<String>(
          //                 value: "Y",
          //                 groupValue: withAccomodation,
          //                 onChanged: (v) => updateAccomodation(v!),
          //               ),
          //               onTap: () => updateAccomodation("Y"),
          //               selected: withAccomodation == "Y",
          //               selectedTileColor: Colors.yellow.shade100,
          //             ),
          //           ),
          //           Expanded(
          //             child: ListTile(
          //               dense: true,
          //               title: const Text('No'),
          //               leading: Radio<String>(
          //                 value: 'N',
          //                 groupValue: withAccomodation,
          //                 onChanged: (v) => updateAccomodation(v!),
          //               ),
          //               onTap: () => updateAccomodation("N"),
          //               selected: withAccomodation == "N",
          //               selectedTileColor: Colors.yellow.shade100,
          //             ),
          //           ),
          //         ],
          //       ),
          //       SizedBox(height: 5),
          //       errorMessageWidget(FormErrorCodes.withAccomodation),

          //       /// Upload button
          //       Divider(),
          //       if (uploadLimited)
          //         GestureDetector(
          //           onTap: () => widget.onError('Image upload is limited to 5 only.'),
          //           child: Row(
          //             children: [
          //               Icon(
          //                 Icons.camera_alt,
          //                 size: 42,
          //                 color: Colors.grey,
          //               ),
          //               SizedBox(width: 10),
          //               Text(
          //                 '* File upload limit reached.\n* Delete and upload again to replace existing image.',
          //                 style: TextStyle(
          //                   color: Colors.orangeAccent,
          //                   fontStyle: FontStyle.italic,
          //                 ),
          //               ),
          //             ],
          //           ),
          //         )
          //       else
          //         FileUploadButton(
          //           child: Row(
          //             children: [
          //               Icon(Icons.camera_alt, size: 42),
          //               SizedBox(width: 10),
          //               Text(
          //                 '* Tap here to upload an image. \n* You can only upload up to 5 images.',
          //                 style: TextStyle(fontStyle: FontStyle.italic),
          //               ),
          //             ],
          //           ),
          //           type: 'post',
          //           onUploaded: (url) {
          //             job.files = [...job.files, url];
          //             if (mounted)
          //               setState(() {
          //                 uploadProgress = 0;
          //               });
          //           },
          //           onProgress: (progress) {
          //             if (mounted) setState(() => uploadProgress = progress);
          //           },
          //           onError: (e) => widget.onError(e),
          //         ),
          //       if (uploadProgress > 0) ...[
          //         SizedBox(height: 8),
          //         LinearProgressIndicator(value: uploadProgress),
          //       ],
          //       if (job.files.isNotEmpty) ...[
          //         SizedBox(height: 8),
          //         ImageListEdit(
          //           files: job.files,
          //           onDeleted: () => setState(() {}),
          //           onError: (e) => widget.onError(e),
          //         ),
          //       ]
          //     ],
          //   ),
          // ),

          Divider(),

          // for (final errCode in errors) Text('${errorMessages[errCode.index]}'),

          /// daesung gimhae
          ElevatedButton(
            onPressed: () async {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Validation success !!')),
                );

                try {
                  if (isCreate) {
                    final created = await FunctionsApi.instance
                        .request('jobCreate', data: job.toCreate, addAuth: true);
                    final newJob = JobModel.fromJson(created);
                    print(newJob);
                  } else {
                    final updated = await FunctionsApi.instance
                        .request('jobUpdate', data: job.toUpdate, addAuth: true);
                    final updatedJob = JobModel.fromJson(updated);
                    print(updatedJob);
                  }
                } catch (e, stacks) {
                  debugPrintStack(stackTrace: stacks);
                  widget.onError(e);
                }
              } else {
                return widget.onError('Validation failed.');
              }

//               final extra = job.toMap;
//               print(extra);

//               String title = "${companyName.text} $salary - ${job.siNm} ${job.sggNm}";
//               String content = """Office No.: ${job.phoneNumber}
// Mobile No.: ${job.mobileNumber}
// Email address: ${job.email}
// Address: ${job.roadAddr}
// Korean Address: ${job.korAddr}

// Job category: ${job.jobCategory}
// No. of hiring: ${job.numberOfHiring}
// About us: ${job.aboutUs}
// requirement:
// duty:
// Salary:
// Working days: in a week
// Working hours: hours
// Accommodation
// Benefit:
// """;
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

  /// Returns a widget if the given code have an error.
  String? errorMessage(FormErrorCodes code) {
    if (isSubmitted && errors.contains(code)) {
      return jobFormErrorMessages[code.index];
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

  validateTextFieldForEmail(TextEditingController controller, FormErrorCodes code) {
    if (EmailValidator.validate(controller.text) == false) {
      errors.add(code);
    } else {
      errors.remove(code);
    }
    setState(() {});
  }
}
