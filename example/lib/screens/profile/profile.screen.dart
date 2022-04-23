import 'package:example/services/global.dart';
import 'package:example/widgets/layout/layout.dart';
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
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: 64,
              ),
            ),
            Text('@TODO: name'),
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
        ),
      ),
    );
  }
}
