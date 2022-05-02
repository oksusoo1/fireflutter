import '../../../fireflutter.dart';
import 'package:flutter/material.dart';

class AdminOnly extends StatelessWidget {
  const AdminOnly({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MyDoc(
      builder: (my) {
        if (my.isAdmin) return child;

        return Center(
          child: Text(
            'You are NOT an admin. Please login as admin.',
            style: TextStyle(color: Colors.red),
          ),
        );
      },
    );
  }
}
