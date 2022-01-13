import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class UserDoc extends StatelessWidget {
  const UserDoc({required this.uid, required this.builder, Key? key})
      : super(key: key);
  final String uid;
  final Widget Function(UserModel) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance.collection('user').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator.adaptive());
        }
        if (snapshot.hasData && snapshot.data!.exists) {
          return builder(UserModel.fromJson(snapshot.data!.data()!));
        } else {
          return builder(UserModel.none());
        }
      },
    );
  }
}
