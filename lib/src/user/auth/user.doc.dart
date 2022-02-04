import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../fireflutter.dart';

/// UserDoc
/// This does not use StreamBuilder since it flashes too much.
class UserDoc extends StatefulWidget {
  const UserDoc({required this.uid, required this.builder, Key? key}) : super(key: key);
  final String uid;
  final Widget Function(UserModel) builder;

  @override
  State<UserDoc> createState() => _UserDocState();
}

class _UserDocState extends State<UserDoc> {
  UserModel? user;

  // ignore: cancel_subscriptions
  StreamSubscription? userDocSubscription;

  DatabaseReference get _doc => FirebaseDatabase.instance.ref('users').child(widget.uid);

  @override
  void initState() {
    super.initState();

    userDocSubscription = _doc.onValue.listen(
      (event) {
        if (event.snapshot.exists) {
          user = UserModel.fromJson(event.snapshot.value);
        } else {
          user = UserModel();
        }
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    if (userDocSubscription != null) userDocSubscription!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return Center(child: CircularProgressIndicator.adaptive());
    return widget.builder(user!);
  }
}
