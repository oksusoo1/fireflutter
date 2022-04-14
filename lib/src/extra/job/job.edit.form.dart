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
    this.post,
  }) : super(key: key);

  final Function(String) onCreated;
  final Function(String) onUpdated;
  final Function(dynamic) onError;

  final PostModel? post;

  @override
  State<JobEditForm> createState() => _JobEditFormState();
}

class _JobEditFormState extends State<JobEditForm> {
  final companyName = TextEditingController();
  final phoneNumber = TextEditingController();
  final mobileNumber = TextEditingController();
  final email = TextEditingController();
  final detailAddress = TextEditingController();
  final aboutUs = TextEditingController();
  final numberOfHiring = TextEditingController();
  final jobDescription = TextEditingController();
  final requirement = TextEditingController();
  final duty = TextEditingController();
  final benefit = TextEditingController();

  final _formKey = GlobalKey<FormState>();

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

  List<String> files = [];
  double uploadProgress = 0;
  bool get uploadLimited => files.length == 5;

  bool get isCreate {
    if (widget.post != null) return false;
    return true;
  }

  bool get isUpdate => !isCreate;

  @override
  initState() {
    super.initState();
    init();
  }

  init() {
    if (isUpdate) {
      // job informations
      final jobInfo = widget.post!.jobInfo;
      // files
      files = widget.post!.files;
      // address
      addr = jobInfo.address;

      companyName.text = jobInfo.companyName;
      phoneNumber.text = jobInfo.phoneNumber;
      mobileNumber.text = jobInfo.mobileNumber;
      email.text = jobInfo.email;
      detailAddress.text = jobInfo.detailAddress;
      aboutUs.text = jobInfo.aboutUs;
      numberOfHiring.text = jobInfo.numberOfHiring;
      jobDescription.text = jobInfo.jobDescription;
      requirement.text = jobInfo.requirement;
      duty.text = jobInfo.duty;
      benefit.text = jobInfo.benefit;

      jobCategory = jobInfo.jobCategory;
      workingDays = jobInfo.workingDays;
      workingHours = jobInfo.workingHours;
      salary = jobInfo.salary;
      withAccomodation = jobInfo.withAccomodation;
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Create a job opening'),

            Divider(height: 30, thickness: 2),
            Text('Company details', style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
            SizedBox(height: 15),

            /// Company name
            JobEditFormTextField(
              label: "Company name",
              initialValue: '',
              onChanged: (v) => '',
              validator: (v) => validateFieldStringValue(v, FormErrorCodes.companyName),
            ),

            /// Company mobile number
            JobEditFormTextField(
              controller: mobileNumber,
              keyboardType: TextInputType.phone,
              label: "Mobile phone number",
              validator: (v) => validateFieldStringValue(v, FormErrorCodes.mobileNumber),
            ),

            /// Company phone number
            JobEditFormTextField(
              controller: phoneNumber,
              keyboardType: TextInputType.phone,
              label: "Office phone number",
              validator: (v) => validateFieldStringValue(v, FormErrorCodes.phoneNumber),
            ),

            /// Company email
            JobEditFormTextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              label: "Email address",
              validator: (v) => validateEmailField(v),
            ),

            /// Company about us
            JobEditFormTextField(
              controller: aboutUs,
              label: "About us",
              maxLines: 5,
              validator: (v) => validateFieldStringValue(v, FormErrorCodes.aboutUs),
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
                  ],
                ),
              ),
            ),

            /// Company detailed address
            if (addr != null) ...[
              JobEditFormTextField(
                controller: detailAddress,
                label: "Input detail address",
                maxLines: 2,
                validator: (v) => validateFieldStringValue(v, FormErrorCodes.detailAddress),
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
                  JobEditFormDropdownField<String>(
                    label: 'Job category',
                    validator: (v) => validateFieldStringValue(v, FormErrorCodes.jobCategory),
                    value: jobCategory,
                    items: [
                      DropdownMenuItem(child: Text('Select job category'), value: ''),
                      ...JobService.instance.categories.entries
                          .map((e) => DropdownMenuItem(
                                child: Text(e.value),
                                value: e.key,
                              ))
                          .toList(),
                    ],
                    onChanged: (s) {
                      setState(() => jobCategory = s ?? '');
                    },
                  ),

                  /// Working days
                  JobEditFormDropdownField<int>(
                    label: 'Working days per week',
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
                    onChanged: (n) => setState(() => workingDays = n ?? -1),
                    validator: (v) => validateFieldIntValue(v, FormErrorCodes.workingDays),
                  ),

                  /// Working hours
                  JobEditFormDropdownField<int>(
                    label: 'Working hour per day',
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
                    onChanged: (n) => setState(() => workingHours = n ?? -1),
                    validator: (v) => validateFieldIntValue(v, FormErrorCodes.workingHours),
                  ),

                  /// Salary
                  JobEditFormDropdownField<String>(
                    label: 'Salary',
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
                    onChanged: (s) => setState(() => salary = s ?? ''),
                    validator: (v) => validateFieldStringValue(v, FormErrorCodes.salary),
                  ),
                ],
              ),
            ),

            /// Job number of hiring
            JobEditFormTextField(
              controller: numberOfHiring,
              keyboardType: TextInputType.number,
              label: "Number of hiring",
              validator: (v) => validateFieldStringValue(v, FormErrorCodes.numberOfHiring),
            ),

            /// Job description
            JobEditFormTextField(
              controller: jobDescription,
              label: "Job description(details of what workers will do)",
              maxLines: 3,
              validator: (v) => validateFieldStringValue(v, FormErrorCodes.jobDescription),
            ),

            /// requirements
            JobEditFormTextField(
              controller: requirement,
              label: "Requirements and qualifications",
              maxLines: 5,
              validator: (v) => validateFieldStringValue(v, FormErrorCodes.requirement),
            ),

            /// duty
            JobEditFormTextField(
              controller: duty,
              label: "Duties and responsibilities",
              maxLines: 5,
              validator: (v) => validateFieldStringValue(v, FormErrorCodes.duty),
            ),

            /// benefit
            JobEditFormTextField(
              controller: benefit,
              label: "benefits(free meals, dormitory, transporation, etc)",
              maxLines: 5,
              validator: (v) => validateFieldStringValue(v, FormErrorCodes.benefit),
            ),

            SizedBox(height: 8),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Accomodation
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
                        files = [...files, url];
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
                  if (files.isNotEmpty) ...[
                    SizedBox(height: 8),
                    ImageListEdit(
                      files: files,
                      onDeleted: () => setState(() {}),
                      onError: (e) => widget.onError(e),
                    ),
                  ]
                ],
              ),
            ),

            Divider(),

            /// Submit button
            ElevatedButton(
              onPressed: onSubmit,
              child: Text('Submit'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> onSubmit() async {
    final isFormValid = _formKey.currentState!.validate();
    if (!isFormValid) {
      widget.onError("Please fill out required field!");
      return;
    }

    final jobInfo = JobInfoModel(
      companyName: companyName.text,
      phoneNumber: phoneNumber.text,
      mobileNumber: mobileNumber.text,
      email: email.text,
      detailAddress: detailAddress.text,
      aboutUs: aboutUs.text,
      numberOfHiring: numberOfHiring.text,
      jobDescription: jobDescription.text,
      requirement: requirement.text,
      duty: duty.text,
      benefit: benefit.text,
      roadAddr: addr?.roadAddr ?? '',
      korAddr: addr?.korAddr ?? '',
      zipNo: addr?.zipNo ?? '',
      siNm: addr?.siNm ?? '',
      sggNm: addr?.sggNm ?? '',
      emdNm: addr?.emdNm ?? '',
      jobCategory: jobCategory,
      salary: salary,
      workingDays: workingDays,
      workingHours: workingHours,
      withAccomodation: withAccomodation,
    );

    final extra = jobInfo.toMap;
    print(extra);

    String title = "${companyName.text} $salary - ${jobInfo.siNm} ${jobInfo.sggNm}";
    String content = """Office No.: ${jobInfo.phoneNumber}
Mobile No.: ${jobInfo.mobileNumber}
Email address: ${jobInfo.email}
Address: ${jobInfo.roadAddr}
Korean Address: ${jobInfo.korAddr}

Job category: ${jobInfo.jobCategory}
No. of hiring: ${jobInfo.numberOfHiring}
About us: ${jobInfo.aboutUs}
requirement: ${jobInfo.requirement}
duty: ${jobInfo.duty}
Salary: ${jobInfo.salary}
Working days (in a week): ${jobInfo.workingDays}
Working hours (in a day): ${jobInfo.workingHours}
With accommodation: ${jobInfo.withAccomodation == 'Y' ? 'Yes' : 'No'}
Benefit: ${jobInfo.benefit}

""";

    try {
      if (isCreate) {
        final create = await PostApi.instance.create(
          category: JobService.instance.jobOpenings,
          title: title,
          content: content,
          files: files,
          extra: extra,
        );
        widget.onCreated(create.id);
      } else {
        final update = await PostApi.instance.update(
          id: widget.post!.id,
          title: title,
          content: content,
          files: files,
          extra: extra,
        );
        widget.onUpdated(update.id);
      }
    } catch (e, stacks) {
      debugPrintStack(stackTrace: stacks);
      widget.onError(e);
    }
  }

  void updateAccomodation(String yN) {
    errors.remove(FormErrorCodes.withAccomodation);
    setState(() => withAccomodation = yN);
  }

  /// Validates string value of a field.
  String? validateFieldStringValue(String? value, FormErrorCodes code) {
    if (value == null || value.isEmpty) return jobFormErrorMessages[code.index];
    return null;
  }

  /// Validates int value of a field.
  String? validateFieldIntValue(int? value, FormErrorCodes code) {
    if (value == null || value < 0) return jobFormErrorMessages[code.index];
    return null;
  }

  /// Validates email value of a field.
  String? validateEmailField(String? value) {
    if (value == null) return jobFormErrorMessages[FormErrorCodes.email];
    if (EmailValidator.validate(value) == false) return "*Please provide a valid email";
    return null;
  }
}
