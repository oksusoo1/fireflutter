import 'package:extended/extended.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  bool nicknameLoader = false;
  bool photoUrlLoader = false;

  final nickname = TextEditingController(text: UserService.instance.user.nickname);
  final photoUrl = TextEditingController(text: UserService.instance.user.photoUrl);

  double uploadProgress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: PagePadding(
        vertical: 16,
        children: [
          UserDoc(
            uid: UserService.instance.user.uid,
            builder: (UserModel u) {
              return FileUploadButton(
                child: u.photoUrl.isNotEmpty
                    ? Image.network(u.photoUrl, height: 100, width: 100, fit: BoxFit.cover)
                    : Icon(Icons.person, size: 40),
                onUploaded: updatePhotoUrl,
                onProgress: (progress) => setState(() => uploadProgress = progress),
                onError: error,
              );
            },
          ),
          spaceSm,
          if (uploadProgress != 0) LinearProgressIndicator(value: uploadProgress),
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
          // const Text('Photo Url'),
          // Row(
          //   children: [
          //     Expanded(
          //       child: TextField(
          //         controller: photoUrl,
          //         decoration: const InputDecoration(
          //           hintText: 'Input photo url',
          //         ),
          //         onChanged: updatePhotoUrl,
          //       ),
          //     ),
          //     if (photoUrlLoader) CircularProgressIndicator.adaptive(),
          //   ],
          // ),
        ],
      ),
    );
  }

  updateNickname(t) {
    setState(() => nicknameLoader = true);
    bounce('nickname', 500, (s) async {
      await UserService.instance.user.updateNickname(t).catchError(error);
      setState(() => nicknameLoader = false);
    });
  }

  updatePhotoUrl(t) {
    // setState(() => photoUrlLoader = true);
    bounce('photo url', 500, (s) async {
      final user = UserService.instance.user;
      /// delete previous profile photo.
      if (user.photoUrl.isNotEmpty) {
        await FileStorageService.instance.delete(user.photoUrl);
      }
      await user.updatePhotoUrl(t).catchError(error);
      setState(() => uploadProgress = 0);
    });
  }
}
