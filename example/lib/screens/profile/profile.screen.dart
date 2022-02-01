import 'package:extended/extended.dart';
import 'package:fe/service/app.controller.dart';
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

  final nickname = TextEditingController(text: AppController.of.user.nickname);
  final photoUrl = TextEditingController(text: AppController.of.user.photoUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: PagePadding(
        vertical: 16,
        children: [
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
          const Text('Photo Url'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: photoUrl,
                  decoration: const InputDecoration(
                    hintText: 'Input photo url',
                  ),
                  onChanged: updatePhotoUrl,
                ),
              ),
              if (photoUrlLoader) CircularProgressIndicator.adaptive(),
            ],
          ),
        ],
      ),
    );
  }

  updateNickname(t) {
    setState(() => nicknameLoader = true);
    bounce('nickname', 500, (s) async {
      await AppController.of.user.updateNickname(t).catchError(error);
      setState(() => nicknameLoader = false);
    });
  }

  updatePhotoUrl(t) {
    setState(() => photoUrlLoader = true);
    bounce('photo url', 500, (s) async {
      await AppController.of.user.updatePhotoUrl(t).catchError(error);
      setState(() => photoUrlLoader = false);
    });
  }
}
