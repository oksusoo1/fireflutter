import 'package:example/services/global.dart';
import 'package:example/widgets/layout/layout.dart';
import 'package:example/widgets/user_avatar/user_avatar.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  static const String routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return Layout(
      backgroundColor: Colors.white,
      title: Text(
        'Profile',
        style: TextStyle(color: Colors.blue),
      ),
      body: SingleChildScrollView(
        child: MyDoc(builder: (my) {
          return Column(
            children: [
              UserPhoto(url: my.photoUrl),
              Text(my.firstName),
              Text('@TODO: your level'),
              Text('@TODO: member since'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: () {}, child: Text('Photo log')),
                  ElevatedButton(
                      onPressed: service.router.openProfileEdit,
                      child: Text('Edit profile')),
                  ElevatedButton(onPressed: () {}, child: Text('...')),
                ],
              ),
              Divider(),
              Text('Recent Reactions'),
              for (int i = 0; i < 100; i++)
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    i.toString(),
                  ),
                )
            ],
          );
        }),
      ),
    );
  }
}
