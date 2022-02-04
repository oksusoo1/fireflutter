import 'package:flutter/material.dart';
import '../../../fireflutter.dart';

class UserFutureDoc extends StatefulWidget {
  const UserFutureDoc({required this.uid, required this.builder, Key? key}) : super(key: key);
  final String uid;
  final Widget Function(UserModel) builder;

  @override
  State<UserFutureDoc> createState() => _UserFutureDocState();
}

class _UserFutureDocState extends State<UserFutureDoc> with DatabaseMixin {
  UserModel? user;

  @override
  void initState() {
    super.initState();

    userDoc(widget.uid).get().then(
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
