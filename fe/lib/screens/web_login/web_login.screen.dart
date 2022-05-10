import 'package:fe/services/defines.dart';
import 'package:fe/widgets/layout/layout.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class WebLoginScreen extends StatelessWidget {
  const WebLoginScreen({
    Key? key,
  }) : super(key: key);

  static const String routeName = '/webLogin';
  @override
  Widget build(BuildContext context) {
    return Layout(
      title: Text('Web login', style: titleStyle),
      body: SignInToken(),
    );
  }
}
