import '../../../fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

class JobSeekerForm extends StatefulWidget {
  JobSeekerForm({
    Key? key,
    required this.onSuccess,
    required this.onError,
  }) : super(key: key);

  final Function onSuccess;
  final Function(String) onError;

  @override
  State<JobSeekerForm> createState() => _JobSeekerFormState();
}

class _JobSeekerFormState extends State<JobSeekerForm> {
  final userService = UserService.instance;

  final labelStyle = TextStyle(fontSize: 12, color: Colors.blueGrey);

  final _formKey = GlobalKey<FormState>(debugLabel: 'jobSeeker');

  final form = JobSeekerModel();
  bool loaded = false;
  bool isSubmitted = false;

  @override
  void initState() {
    super.initState();
    form.load(uid: userService.uid).then((x) => setState(() => loaded = true));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        UserProfilePhoto(uid: userService.uid, size: 100),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text('First Name', style: labelStyle),
                SizedBox(height: 5),
                Text('${userService.user.firstName}'),
              ],
            ),
            Column(
              children: [
                Text('Middle Name', style: labelStyle),
                SizedBox(height: 5),
                Text('${userService.user.middleName}'),
              ],
            ),
            Column(
              children: [
                Text('Last Name', style: labelStyle),
                SizedBox(height: 5),
                Text('${userService.user.lastName}'),
              ],
            ),
          ],
        ),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text('Email Address', style: labelStyle),
                SizedBox(height: 5),
                Text('${userService.user.email}'),
              ],
            ),
            Column(
              children: [
                Text('Gender', style: labelStyle),
                SizedBox(height: 5),
                Text('${userService.user.gender}'),
              ],
            ),
            Column(
              children: [
                Text('Phone number', style: labelStyle),
                SizedBox(height: 5),
                Text('${userService.user.phoneNumber}'),
              ],
            ),
          ],
        ),
        Divider(height: 30),
        loaded == false
            ? Container(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              )
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    JobFormTextField(
                      label: 'Proficiency',
                      initialValue: form.proficiency,
                      onChanged: (s) => form.proficiency = s,
                      validator: (s) => validateFieldValue(s, "* Please enter proficiency."),
                      maxLines: 5,
                    ),
                    SizedBox(height: 8),
                    // TextFormField(
                    //   initialValue: form.skills,
                    //   decoration: InputDecoration(labelText: 'Skills'),
                    //   minLines: 2,
                    //   maxLines: 5,
                    //   onChanged: (s) => form.skills = s,
                    // ),
                    SizedBox(height: 8),
                    JobFormTextField(
                      label: "Years of experience",
                      initialValue: form.experiences,
                      onChanged: (s) => form.experiences = s,
                      validator: (s) =>
                          validateFieldValue(s, "* Please enter years of experience."),
                      maxLines: 5,
                    ),
                    SizedBox(height: 10),
                    Text("Location", style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: JobFormDropdownField<String>(
                            validator: (v) => validateFieldValue(v, "* Please select location."),
                            onChanged: (v) => setState(() => form.siNm = v ?? ''),
                            value: form.siNm,
                            items: [
                              DropdownMenuItem(
                                child: Text('Select location'),
                                value: '',
                              ),
                              ...JobService.instance.areas.entries
                                  .map((e) => DropdownMenuItem(
                                        child: Text(e.key, style: TextStyle(fontSize: 14)),
                                        value: e.key,
                                      ))
                                  .toList(),
                            ],
                          ),
                        ),
                        if (form.siNm.isNotEmpty) ...[
                          SizedBox(width: 10),
                          Expanded(
                            child: JobFormDropdownField<String>(
                              validator: (v) => validateFieldValue(v, "* Please select location"),
                              onChanged: (v) => form.sggNm = v ?? '',
                              value: form.sggNm,
                              items: [
                                DropdownMenuItem(
                                  child: Text('Select location'),
                                  value: '',
                                ),
                                for (String sggNm in JobService.instance.areas[form.siNm]!)
                                  DropdownMenuItem(
                                    child: Text(sggNm, style: TextStyle(fontSize: 14)),
                                    value: sggNm,
                                  )
                              ],
                            ),
                          ),
                        ]
                      ],
                    ),
                    SizedBox(height: 10),
                    JobFormDropdownField<String>(
                      label: "What industry would you like to work in?",
                      value: form.industry,
                      items: [
                        DropdownMenuItem(child: Text('Select industry'), value: ''),
                        DropdownMenuItem(child: Text('Any kind of industry'), value: 'any'),
                        ...JobService.instance.categories.entries
                            .map((e) => DropdownMenuItem(
                                  child: Text(e.value),
                                  value: e.key,
                                ))
                            .toList(),
                      ],
                      onChanged: (v) => form.industry = v ?? '',
                      validator: (s) => validateFieldValue(s, "* Please select an industry."),
                    ),

                    SizedBox(height: 8),
                    JobFormTextField(
                      label: 'What do you expect on your future job?',
                      initialValue: form.comment,
                      onChanged: (s) => form.comment = s,
                      validator: (s) => validateFieldValue(s, "* Please enter your expectations."),
                      maxLines: 5,
                    ),
                    Divider(),
                    ElevatedButton(onPressed: onSubmit, child: Text('Submit'))
                  ],
                ),
              )
      ],
    );
  }

  onSubmit() async {
    setState(() => isSubmitted = true);
    if (_formKey.currentState!.validate()) {
      print('JobSeekerForm::onSubmit::form');
      print('${form.toString()}');
      try {
        await form.update();
        widget.onSuccess();
      } catch (e) {
        widget.onError(e.toString());
      }
    } else {
      print('validation error');
    }
  }

  String? validateFieldValue(dynamic value, String error) {
    if (isSubmitted) {
      if (value == null) return error;
      if (value is String && value.trim().isEmpty) return error;
      if (value is int && value < 0) return error;
    }
    return null;
  }
}

/// all the info from porofile.
// - photo url, first, middle, last name, birthday, gender, email, phone number …

// professioncy
// skills, experience

// what industry I would like to work;
// …

// comment and expectation for future job.
