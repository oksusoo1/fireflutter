import 'dart:async';

import 'package:flutter/material.dart';
import '../../../fireflutter.dart';

/// MyDoc
///
///
class MyDoc extends StatefulWidget {
  const MyDoc({required this.builder, Key? key}) : super(key: key);
  final Widget Function(UserModel) builder;

  @override
  State<MyDoc> createState() => _MyDocState();
}

class _MyDocState extends State<MyDoc> {
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
    if (user == null) {
      return const Center(
        child: SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator.adaptive(
            strokeWidth: 2,
          ),
        ),
      );
    }
    return widget.builder(user!);
  }
}
