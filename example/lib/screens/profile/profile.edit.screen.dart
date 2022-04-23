import 'package:example/widgets/layout/layout.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  static const String routeName = '/profileEdit';

  @override
  Widget build(BuildContext context) {
    return Layout(
      backgroundColor: Colors.white,
      title: Text(
        'Profile Edit',
        style: TextStyle(color: Colors.blue),
      ),
      body: SingleChildScrollView(
        child: UserDoc(
          uid: UserService.instance.uid,
          builder: (user) => Column(
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
      ),
    );
  }
}
