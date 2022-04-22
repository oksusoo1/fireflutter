// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../../fireflutter.dart';

/// UserDoc
///
class UserDoc extends StatefulWidget {
  const UserDoc({
    required this.uid,
    required this.builder,
    this.loader = const Center(
      child: SizedBox(
        width: 10,
        height: 10,
        child: CircularProgressIndicator.adaptive(
          strokeWidth: 2,
        ),
      ),
    ),
    Key? key,
  }) : super(key: key);
  final String uid;
  final Widget loader;
  final Widget Function(UserModel) builder;

  @override
  State<UserDoc> createState() => _UserDocState();
}

class _UserDocState extends State<UserDoc> {
  UserModel? user;

  @override
  void initState() {
    super.initState();

    UserService.instance.getOtherUserDoc(widget.uid).then((v) {
      if (mounted) setState(() => user = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return widget.loader;
    return widget.builder(user!);
  }
}
