import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fireflutter.dart';
import 'package:flutter/material.dart';

class UserFutureDoc extends StatefulWidget {
  const UserFutureDoc({required this.uid, required this.builder, Key? key}) : super(key: key);
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

    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists) {
        user = UserModel.fromJson(snapshot.data()!);
      } else {
        user = UserModel.nonExist();
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return Center(child: CircularProgressIndicator.adaptive());
    return widget.builder(user!);
  }
}
