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

  @override
  void initState() {
    super.initState();
    form.load(uid: UserService.instance.uid).then((x) => setState(() => loaded = true));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatar(),
        Text('First Name', style: labelStyle),
        Text('${UserService.instance.user.firstName}'),
        SizedBox(height: 8),
        Text('Middle Name', style: labelStyle),
        Text('${UserService.instance.user.middleName}'),
        SizedBox(height: 8),
        Text('Last Name', style: labelStyle),
        Text('${UserService.instance.user.lastName}'),
        SizedBox(height: 8),
        Text('Email Address', style: labelStyle),
        Text('${UserService.instance.user.email}'),
        SizedBox(height: 8),
        Text('Phone number', style: labelStyle),
        Text('${UserService.instance.user.phoneNumber}'),
        SizedBox(height: 8),
        Text('Gender', style: labelStyle),
        Text('${UserService.instance.user.gender}'),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: form.proficiency,
                      decoration: InputDecoration(labelText: 'Proficiency'),
                      minLines: 2,
                      maxLines: 5,
                      onChanged: (s) => form.proficiency = s,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      initialValue: form.skills,
                      decoration: InputDecoration(labelText: 'Skills'),
                      minLines: 2,
                      maxLines: 5,
                      onChanged: (s) => form.skills = s,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      initialValue: form.experiences,
                      decoration: InputDecoration(labelText: 'Years of experience'),
                      minLines: 2,
                      maxLines: 5,
                      onChanged: (s) => form.experiences = s,
                    ),
                    SizedBox(height: 8),
                    Text('What industry would you like to work in?'),
                    DropdownButtonFormField<String>(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? '* Please select an industry' : null,
                      onChanged: (v) => form.industry = v ?? '',
                      value: form.industry,
                      items: [
                        DropdownMenuItem(
                          child: Text('Select industry'),
                          value: '',
                        ),
                        DropdownMenuItem(
                          child: Text('Any kind of industry'),
                          value: 'any',
                        ),
                        ...JobService.instance.categories.entries
                            .map((e) => DropdownMenuItem(
                                  child: Text(e.value),
                                  value: e.key,
                                ))
                            .toList(),
                      ],
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      initialValue: form.comment,
                      decoration:
                          InputDecoration(labelText: 'What do you expect on your future job?'),
                      minLines: 2,
                      maxLines: 5,
                      onChanged: (s) => form.comment = s,
                    ),
                    ElevatedButton(onPressed: onSubmit, child: Text('Submit'))
                  ],
                ),
              )
      ],
    );
  }

  onSubmit() async {
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
}

/// all the info from porofile.
// - photo url, first, middle, last name, birthday, gender, email, phone number …

// professioncy
// skills, experience

// what industry I would like to work;
// …

// comment and expectation for future job.
