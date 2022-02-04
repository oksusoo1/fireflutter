import 'package:firebase_database/firebase_database.dart';
import '../../../fireflutter.dart';
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

  /// TODO: Move it to FirebaseCode. And change FirebaseBase to FirebaseCode.
  DatabaseReference get _doc => FirebaseDatabase.instance.ref('users').child(widget.uid);

  @override
  void initState() {
    super.initState();

    _doc.get().then(
      (event) {
        if (event.exists) {
          user = UserModel.fromJson(event.value);
        } else {
          user = UserModel();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return Center(child: CircularProgressIndicator.adaptive());
    return widget.builder(user!);
  }
}
