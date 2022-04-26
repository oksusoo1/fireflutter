import 'package:example/services/defines.dart';
import 'package:example/widgets/layout/layout.dart';
import 'package:example/widgets/user_avatar/user_avatar.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

enum Gender { M, F }

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  static const String routeName = '/profileEdit';

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final email = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final middleName = TextEditingController();
  double progress = 0;

  updateProgress(double progress) {
    debugPrint('progress; $progress ...');
    setState(() => this.progress = progress);
  }

  @override
  void initState() {
    super.initState();
    email.text = UserService.instance.email;
    firstName.text = UserService.instance.firstName;
    middleName.text = UserService.instance.middleName;
    lastName.text = UserService.instance.lastName;
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      backButton: true,
      backgroundColor: Colors.white,
      title: Text(
        'Profile Edit',
        style: TextStyle(color: Colors.blue),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('@TODO: UI - 사진에 카메라 표시. 삭제 버튼 표시.'),
              Text('@TODO: UX - 사용자가 입력을 하면 로더표시 후 저장완료 표시.'),
              MyDoc(builder: (my) {
                return FileUploadButton(
                  child: UserPhoto(url: my.photoUrl, progress: progress),
                  type: 'user',
                  onUploaded: (url) => my.updatePhotoUrl(url).then((x) => updateProgress(0)),
                  onProgress: updateProgress,
                );
              }),
              MyDoc(
                builder: (user) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: firstName,
                      decoration: InputDecoration(
                        label: Text('First name'),
                      ),
                      onChanged: user.updateFirstName,
                    ),
                    TextField(
                      controller: middleName,
                      decoration: InputDecoration(
                        label: Text('Middle name'),
                      ),
                      onChanged: user.updateMiddleName,
                    ),
                    TextField(
                      controller: lastName,
                      decoration: InputDecoration(
                        label: Text('Last name'),
                      ),
                      onChanged: user.updateLastName,
                    ),
                    TextField(
                      controller: email,
                      decoration: InputDecoration(
                        label: Text('Email'),
                      ),
                      onChanged: user.updateEmail,
                    ),
                    spaceSm,
                    Text('Gender', style: hintStyle),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<Gender>(
                            value: Gender.M,
                            groupValue: Gender.values.asNameMap()[user.gender],
                            title: Text('Male'),
                            onChanged: (g) {
                              setState(() {});
                              user.updateGender(g!.name);
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<Gender>(
                            value: Gender.F,
                            groupValue: Gender.values.asNameMap()[user.gender],
                            title: Text('Female'),
                            onChanged: (g) {
                              setState(() {});
                              user.updateGender(g!.name);
                            },
                          ),
                        ),
                      ],
                    ),
                    spaceSm,
                    Text('Birthday', style: hintStyle),
                    DatePicker(initialValue: user.birthday, onChanged: user.updateBirthday)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
