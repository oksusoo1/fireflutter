import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../fireflutter.dart';
import 'package:flutter/material.dart';

class UserDoc extends StatefulWidget {
  const UserDoc({required this.uid, required this.builder, Key? key}) : super(key: key);
  final String uid;
  final Widget Function(UserModel) builder;

  @override
  State<UserDoc> createState() => _UserDocState();
}

class _UserDocState extends State<UserDoc> {
  UserModel? user;

  late StreamSubscription userDocSubscription;
  @override
  void initState() {
    super.initState();

    userDocSubscription =
        FirebaseFirestore.instance.collection('users').doc(widget.uid).snapshots().listen(
      (DocumentSnapshot<Map<String, dynamic>> snapshot) {
        setState(() {
          if (snapshot.exists) {
            user = UserModel.fromJson(snapshot.data()!);
          } else {
            user = UserModel();
          }
        });
      },
    );
  }

  @override
  void dispose() {
    userDocSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return Center(child: CircularProgressIndicator.adaptive());
    return widget.builder(user!);

    // return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    //   stream: FirebaseFirestore.instance.collection('user').doc(widget.uid).snapshots(),
    //   builder: (context, snapshot) {
    //     if (snapshot.hasError) {
    //       return Text('Something went wrong');
    //     }
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return Center(child: CircularProgressIndicator.adaptive());
    //     }
    //     if (snapshot.hasData && snapshot.data!.exists) {
    //       return widget.builder(UserModel.fromJson(snapshot.data!.data()!));
    //     } else {
    //       return widget.builder(UserModel.nonExist());
    //     }
    //   },
    // );
  }
}
