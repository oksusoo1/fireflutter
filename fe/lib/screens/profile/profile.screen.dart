import 'package:extended/extended.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  static const String routeName = '/profile';

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  bool nicknameLoader = false;
  bool photoUrlLoader = false;
  bool emailLoader = false;

  final nickname =
      TextEditingController(text: UserService.instance.user.nickname);
  final photoUrl =
      TextEditingController(text: UserService.instance.user.photoUrl);
  final email = TextEditingController(text: UserService.instance.email);

  double uploadProgress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: PagePadding(
          vertical: 16,
          children: [
            MyDoc(
              builder: (UserModel u) {
                return FileUploadButton(
                  child: u.photoUrl.isNotEmpty
                      ? UploadedImage(url: u.photoUrl)
                      : Icon(Icons.person, size: 40),
                  type: 'user',
                  onUploaded: updatePhotoUrl,
                  onProgress: (progress) =>
                      setState(() => uploadProgress = progress),
                  onError: error,
                );
              },
            ),
            spaceSm,
            if (uploadProgress != 0)
              LinearProgressIndicator(value: uploadProgress),
            spaceXl,
            const Text('Nickname'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nickname,
                    decoration: const InputDecoration(hintText: 'Nickname'),
                    onChanged: updateNickname,
                  ),
                ),
                if (nicknameLoader) CircularProgressIndicator.adaptive(),
              ],
            ),
            spaceXl,
            const Text('Email'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                      controller: email,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        helperText:
                            'Note: this will update email field on the user settings under realtime database.',
                      ),
                      onChanged: updateEmail),
                ),
                if (emailLoader) CircularProgressIndicator.adaptive(),
              ],
            ),
            TextField(
              controller: TextEditingController()
                ..text = UserService.instance.user.firstName,
              decoration: const InputDecoration(
                hintText: 'First name',
                helperText: 'Input first name',
              ),
              onChanged: (s) => UserService.instance.user
                  .update(field: 'firstName', value: s)
                  .catchError((e) => error(e)),
            ),
            TextField(
              controller: TextEditingController()
                ..text = UserService.instance.user.lastName,
              decoration: const InputDecoration(
                hintText: 'Last name',
                helperText: 'Input last name',
              ),
              onChanged: (s) => UserService.instance.user
                  .update(field: 'lastName', value: s)
                  .catchError((e) => error(e)),
            ),
            TextField(
              controller: TextEditingController()
                ..text = UserService.instance.user.gender,
              decoration: const InputDecoration(
                hintText: 'Gender',
                helperText: 'Input gender as in M or F',
              ),
              onChanged: (s) => UserService.instance.user
                  .update(field: 'gender', value: s)
                  .catchError((e) => error(e)),
            ),
            TextField(
              controller: TextEditingController()
                ..text = UserService.instance.user.birthday.toString(),
              decoration: const InputDecoration(
                hintText: 'Birthday',
                helperText: 'Input birthday as in the format of YYYYMMDD',
              ),
              onChanged: (s) => UserService.instance.user
                  .update(field: 'birthday', value: s)
                  .catchError((e) => error(e)),
            ),
          ],
        ),
      ),
    );
  }

  updateNickname(t) {
    setState(() => nicknameLoader = true);
    bounce('nickname', 500, (s) async {
      await UserService.instance.user
          .updateNickname(t)
          .catchError((e) => error(e));
      setState(() => nicknameLoader = false);
    });
  }

  updateEmail(t) {
    setState(() => emailLoader = true);
    bounce('nickname', 500, (s) async {
      await UserService.instance.user
          .update(field: 'email', value: t)
          .catchError((e) => error(e));
      setState(() => emailLoader = false);
    });
  }

  updatePhotoUrl(t) async {
    final user = UserService.instance.user;
    // print('photoUrl ===> $t');
    try {
      if (user.photoUrl.isNotEmpty) {
        await StorageService.instance.delete(user.photoUrl);
      }
      await user.updatePhotoUrl(t).catchError((e) => error(e));
      setState(() => uploadProgress = 0);
    } catch (e) {
      // debugPrint('updatePhotoUrl() => StorageService.instance.delete(${user.photoUrl})');
      error(e);
    }
  }
}
