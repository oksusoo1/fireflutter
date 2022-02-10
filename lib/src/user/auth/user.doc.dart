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
  late StreamSubscription sub;

  @override
  void initState() {
    super.initState();

    sub = UserService.instance.changes.listen((v) => setState(() => user = v));
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return Center(child: CircularProgressIndicator.adaptive());
    return widget.builder(user!);
  }
}
