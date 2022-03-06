import 'package:flutter/material.dart';
import '../../../fireflutter.dart';

class UserSignedIn extends StatelessWidget {
  const UserSignedIn({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MyDoc(builder: (u) {
      if (u.signedIn)
        return child;
      else
        return SizedBox.shrink();
    });
  }
}
