import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../fireflutter.dart';
import 'package:flutter/material.dart';

class UserFutureDoc extends StatefulWidget {
  const UserFutureDoc({required this.uid, required this.builder, Key? key})
      : super(key: key);
  final String uid;
  final Widget Function(UserModel) builder;

  @override
  State<UserFutureDoc> createState() => _UserFutureDocState();
}

class _UserFutureDocState extends State<UserFutureDoc> {
  UserModel? user;
  @override
  void initState() {
    super.initState();

    if (UserService.instance.otherUsersData[widget.uid] != null) {
      setState(() {
        user = UserService.instance.otherUsersData[widget.uid];
      });
      return;
    }
    FirebaseFirestore.instance.collection('users').doc(widget.uid).get().then(
      (DocumentSnapshot<Map<String, dynamic>> snapshot) {
        setState(() {
          if (snapshot.exists) {
            user = UserModel.fromJson(snapshot.data()!);
            UserService.instance.otherUsersData[widget.uid] = user!;
          } else {
            user = UserModel();
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null)
      return Center(child: CircularProgressIndicator.adaptive());
    return widget.builder(user!);
  }
}
