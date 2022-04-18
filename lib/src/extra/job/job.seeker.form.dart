import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

class JobSeekerModel {
  String firstName = '';
  String middleName = '';
  String lastName = '';
  String email = '';
  String phoneNumber = '';
  String gender = '';
  String proficiency = '';
  String skills = '';
  String experiences = '';
  String industry = '';
  String comment = '';
}

class JobSeekerForm extends StatefulWidget {
  JobSeekerForm({Key? key}) : super(key: key);

  @override
  State<JobSeekerForm> createState() => _JobSeekerFormState();
}

class _JobSeekerFormState extends State<JobSeekerForm> {
  final userService = UserService.instance;

  final labelStyle = TextStyle(fontSize: 12, color: Colors.blueGrey);

  final _formKey = GlobalKey<FormState>(debugLabel: 'jobSeeker');

  final formData = JobSeekerModel();

  @override
  void initState() {
    formData.firstName = userService.user.firstName;
    formData.middleName = userService.user.middleName;
    formData.lastName = userService.user.lastName;
    formData.email = userService.user.email;
    formData.phoneNumber = userService.user.phoneNumber;
    formData.gender = userService.user.gender;
    super.initState();
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
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: formData.proficiency,
                decoration: InputDecoration(labelText: 'Proficiency'),
                minLines: 2,
                maxLines: 5,
              ),
              SizedBox(height: 8),
              TextFormField(
                initialValue: formData.skills,
                decoration: InputDecoration(labelText: 'Skills'),
                minLines: 2,
                maxLines: 5,
              ),
              SizedBox(height: 8),
              TextFormField(
                initialValue: formData.experiences,
                decoration: InputDecoration(labelText: 'Working experiences'),
                minLines: 2,
                maxLines: 5,
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? '* Please select an industry' : null,
                onChanged: (v) => formData.industry = v ?? '',
                value: formData.industry,
                items: [
                  DropdownMenuItem(
                    child: Text('What industry would you like to work in?'),
                    value: '',
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
                initialValue: formData.comment,
                decoration: InputDecoration(labelText: 'What do you expect on your future job?'),
                minLines: 2,
                maxLines: 5,
              ),
              ElevatedButton(onPressed: onSubmit, child: Text('Submit'))
            ],
          ),
        )
      ],
    );
  }

  onSubmit() {
    if (_formKey.currentState!.validate()) {
      print('JobSeekerForm::onSubmit::formData');
      print('${formData.toString()}');
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
