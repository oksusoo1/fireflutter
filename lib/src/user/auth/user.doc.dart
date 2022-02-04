import 'dart:async';

import 'package:flutter/material.dart';
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

class _UserDocState extends State<UserDoc> with DatabaseMixin {
  UserModel? user;

  // ignore: cancel_subscriptions
  StreamSubscription? userDocSubscription;

  @override
  void initState() {
    super.initState();

    userDocSubscription = userDoc(widget.uid).onValue.listen(
      (event) {
        if (event.snapshot.exists) {
          user = UserModel.fromJson(event.snapshot.value, event.snapshot.key!);
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
