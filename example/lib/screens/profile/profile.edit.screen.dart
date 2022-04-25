import 'package:example/widgets/layout/layout.dart';
import 'package:example/widgets/user_avatar/user_avatar.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  static const String routeName = '/profileEdit';

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  double progress = 0;

  updateProgress(double progress) {
    debugPrint('progress; $progress ...');
    setState(() => this.progress = progress);
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
              MyDoc(builder: (my) {
                return FileUploadButton(
                  child: UserPhoto(url: my.photoUrl, progress: progress),
                  type: 'user',
                  onUploaded: (url) => my.updatePhotoUrl(url).then((x) => updateProgress(0)),
                  onProgress: updateProgress,
                );
              }),
              UserDoc(
                uid: UserService.instance.uid,
                reset: true,
                builder: (user) => Column(
                  children: [
                    TextField(
                      controller: TextEditingController()..text = user.firstName,
                      decoration: InputDecoration(
                        label: Text('First name'),
                      ),
                      onChanged: (s) => user.update(field: 'firstName', value: s),
                    ),
                    Text('@TODO: your level'),
                    Text('@TODO: member since'),
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
