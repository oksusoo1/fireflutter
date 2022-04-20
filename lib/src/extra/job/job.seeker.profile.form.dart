import '../../../fireflutter.dart';
import 'package:flutter/material.dart';

class JobSeekerProfileForm extends StatefulWidget {
  JobSeekerProfileForm({
    Key? key,
    required this.onSuccess,
    required this.onError,
  }) : super(key: key);

  final Function onSuccess;
  final Function(String) onError;

  @override
  State<JobSeekerProfileForm> createState() => _JobSeekerProfileFormState();
}

class _JobSeekerProfileFormState extends State<JobSeekerProfileForm> {
  final labelStyle = TextStyle(fontSize: 12, color: Colors.blueGrey);
  final _formKey = GlobalKey<FormState>(debugLabel: 'jobSeeker');
  final userService = UserService.instance;
  final form = JobSeekerModel();

  bool loaded = false;
  bool loading = false;
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
                Text('Phone number', style: labelStyle),
                SizedBox(height: 5),
                Text('${userService.user.phoneNumber}'),
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
                Text('Gender', style: labelStyle),
                SizedBox(height: 5),
                Text('${userService.user.gender}'),
              ],
            ),
            Column(
              children: [
                Text('Birthdate', style: labelStyle),
                SizedBox(height: 5),
                Text('${userService.user.birthday}'),
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
                    SizedBox(height: 8),
                    JobFormTextField(
                      label: "Years of experience",
                      initialValue: form.experiences,
                      onChanged: (s) => form.experiences = s,
                      validator: (s) => validateFieldValue(
                        s,
                        "* Please enter years of experience.",
                      ),
                    ),
                    SizedBox(height: 10),
                    Text("Location", style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: JobFormDropdownField<String>(
                            value: form.siNm,
                            onChanged: (v) => setState(() => form.siNm = v ?? ''),
                            validator: (v) => validateFieldValue(v, "* Please select location."),
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
                              value: form.sggNm,
                              onChanged: (v) => form.sggNm = v ?? '',
                              validator: (v) => validateFieldValue(
                                v,
                                "* Please select city/county/gu.",
                              ),
                              items: [
                                DropdownMenuItem(
                                  child: Text('Select city/county/gu'),
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
                        ...JobService.instance.categories.entries
                            .map((e) => DropdownMenuItem(
                                  child: Text(e.value),
                                  value: e.key,
                                ))
                            .toList(),
                      ],
                      onChanged: (v) => form.industry = v ?? '',
                      validator: (s) => validateFieldValue(
                        s,
                        "* Please select your desired industry.",
                      ),
                    ),
                    SizedBox(height: 8),
                    JobFormTextField(
                      label: 'What do you expect on your future job?',
                      initialValue: form.comment,
                      onChanged: (s) => form.comment = s,
                      validator: (s) => validateFieldValue(
                        s,
                        "* Please enter your comments or expections about your future job.",
                      ),
                      maxLines: 5,
                    ),
                    Divider(),
                    if (loading)
                      Center(child: CircularProgressIndicator.adaptive(strokeWidth: 2))
                    else
                      ElevatedButton(onPressed: onSubmit, child: Text('UPDATE'))
                  ],
                ),
              )
      ],
    );
  }

  onSubmit() async {
    setState(() {
      isSubmitted = true;
      loading = true;
    });
    if (userService.user.profileError.isNotEmpty) {
      widget.onError(userService.user.profileError);
    } else if (_formKey.currentState!.validate()) {
      print('JobSeekerProfileForm::onSubmit::form');
      print('${form.toString()}');
      try {
        await form.update();
        widget.onSuccess();
      } catch (e) {
        widget.onError(e.toString());
      }
    }
    setState(() => loading = false);
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
