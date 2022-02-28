import '../../../fireflutter.dart';
import 'package:flutter/material.dart';

class UserName extends StatelessWidget {
  const UserName({required this.uid, this.style, this.maxLines, this.overflow, Key? key})
      : super(key: key);
  final String uid;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  @override
  Widget build(BuildContext context) {
    return UserDoc(
      uid: uid,
      loader: SizedBox.shrink(),
      builder: (u) => Text(
        u.displayName,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
