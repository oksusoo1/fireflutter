import '../../../fireflutter.dart';
import 'package:flutter/material.dart';

class UserName extends StatelessWidget {
  const UserName({required this.uid, this.style, Key? key}) : super(key: key);
  final String uid;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) {
    return UserDoc(
      uid: uid,
      loader: SizedBox.shrink(),
      builder: (u) => Text(
        u.displayName,
        style: style,
      ),
    );
  }
}
