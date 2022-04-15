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

  JobModel job = JobModel.empty();
  bool get isCreate {
    return widget.job == null;
  }

  bool get isUpdate => !isCreate;

  double uploadProgress = 0;
  bool get uploadLimited => job.files.length >= 5;

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
    setState(() {});
  }

  /// Validates string value of a field.
  String? validateFieldValue(dynamic value, String error) {
    if (value == null) return error;
    if (value is String && value.isEmpty) return error;
    if (value is int && value < 0) return error;
    return null;
  }

  String? validateEmailFieldStringValue(String? value) {
    return EmailValidator.validate(value ?? '')
        ? null
        : "*Please input correct company email address.";
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Create a job opening'),

          Divider(height: 30, thickness: 2),
          Text('Company details', style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
          SizedBox(height: 15),

          JobEditFormTextField(
            label: "Company name",
            initialValue: job.companyName,
            onChanged: (s) => job.companyName = s,
            validator: (v) => validateFieldValue(v, "*Please input company name."),
          ),
          SizedBox(height: 10),

          JobEditFormTextField(
            label: "Mobile number",
            initialValue: job.mobileNumber,
            onChanged: (s) => job.mobileNumber = s,
            validator: (v) => validateFieldValue(v, "*Please input company mobile number."),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 10),

          JobEditFormTextField(
            label: 'Office phone number number',
            initialValue: job.phoneNumber,
            onChanged: (s) => job.phoneNumber = s,
            validator: (v) => validateFieldValue(v, "*Please input company office phone number."),
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 10),

          JobEditFormTextField(
            label: 'Email Address',
            initialValue: job.email,
            onChanged: (s) => job.email = s,
            validator: (v) => validateEmailFieldStringValue(v),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 10),

          JobEditFormTextField(
            label: "About us",
            initialValue: job.aboutUs,
            onChanged: (s) => job.aboutUs = s,
            validator: (v) => validateFieldValue(v, "*Please tell something about your company."),
            maxLines: 5,
          ),
          SizedBox(height: 10),

          /// TODO: make it simple
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
                ],
              ),
            ),
          ),

          /// Company detailed address
          if (addr != null)
            JobEditFormTextField(
              label: "Input detail address",
              initialValue: job.detailAddress,
              onChanged: (s) => job.detailAddress = s,
              validator: (v) => validateFieldValue(v, "*Please input a detailed address."),
              maxLines: 2,
            ),

          JobEditFormDropdownField<String>(
            label: "Job category",
            value: job.jobCategory,
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
            onChanged: (s) => setState(() => job.jobCategory = s ?? ''),
            validator: (s) => validateFieldValue(s, "*Please select job category."),
          ),

          JobEditFormDropdownField<int>(
            label: "Working days (per week)",
            value: job.workingDays,
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
            onChanged: (n) => setState(() => job.workingDays = n ?? -1),
            validator: (n) =>
                validateFieldValue(n, "*Please select the number of days to work per week."),
          ),

          JobEditFormDropdownField<int>(
            label: "Working hours (per day)",
            value: job.workingHours,
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
            onChanged: (n) => setState(() => job.workingHours = n ?? -1),
            validator: (n) =>
                validateFieldValue(n, "*Please select the number of hours to work per day."),
          ),

          JobEditFormDropdownField<String>(
            label: "Salary",
            value: job.salary,
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
            onChanged: (s) => setState(() => job.salary = s ?? ""),
            validator: (n) => validateFieldValue(n, "*Please select a salary to offer."),
          ),
          SizedBox(height: 10),

          JobEditFormTextField(
            label: "Number of hiring",
            initialValue: job.numberOfHiring,
            onChanged: (s) => job.numberOfHiring = s,
            validator: (v) =>
                validateFieldValue(v, "*Please input number of available slot for hiring."),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 10),

          JobEditFormTextField(
            label: "Job description(details of what workers will do)",
            initialValue: job.description,
            onChanged: (s) => job.description = s,
            validator: (v) => validateFieldValue(v, "*Please describe something about the job."),
            maxLines: 3,
          ),
          SizedBox(height: 10),

          JobEditFormTextField(
            label: "Requirements and qualifications",
            initialValue: job.requirement,
            onChanged: (s) => job.requirement = s,
            validator: (v) =>
                validateFieldValue(v, "*Please enumerate the requirements for the job."),
            maxLines: 5,
          ),
          SizedBox(height: 10),

          JobEditFormTextField(
            label: "Duties and responsibilities",
            initialValue: job.duty,
            onChanged: (s) => job.duty = s,
            validator: (v) => validateFieldValue(v, "*Please enumerate the duties of the job."),
            maxLines: 5,
          ),
          SizedBox(height: 10),

          JobEditFormTextField(
            label: "benefits(free meals, dormitory, transporation, etc)",
            initialValue: job.benefit,
            onChanged: (s) => job.benefit = s,
            validator: (v) =>
                validateFieldValue(v, "*Please enumerate the benefit given for the job."),
            maxLines: 5,
          ),
          SizedBox(height: 10),

          JobEditAccomodationRadioField(
            initialValue: job.withAccomodation,
            validator: (v) => validateFieldValue(
              v,
              "*Please select if the job includes an accomodation.",
            ),
          ),

          /// Upload button
          Divider(),
          if (uploadLimited)
            GestureDetector(
              onTap: () => widget.onError('Image upload is limited to 5 only.'),
              child: Row(
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 42,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 10),
                  Text(
                    '* File upload limit reached.\n* Delete and upload again to replace existing image.',
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )
          else
            FileUploadButton(
              child: Row(
                children: [
                  Icon(Icons.camera_alt, size: 42),
                  SizedBox(width: 10),
                  Text(
                    '* Tap here to upload an image. \n* You can only upload up to 5 images.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              type: 'post',
              onUploaded: (url) {
                job.files = [...job.files, url];
                if (mounted)
                  setState(() {
                    uploadProgress = 0;
                  });
              },
              onProgress: (progress) {
                if (mounted) setState(() => uploadProgress = progress);
              },
              onError: (e) => widget.onError(e),
            ),
          if (uploadProgress > 0) ...[
            SizedBox(height: 8),
            LinearProgressIndicator(value: uploadProgress),
          ],
          if (job.files.isNotEmpty) ...[
            SizedBox(height: 8),
            ImageListEdit(
              files: job.files,
              onDeleted: () => setState(() {}),
              onError: (e) => widget.onError(e),
            ),
          ],

          Divider(),

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
}
