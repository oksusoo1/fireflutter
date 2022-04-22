import 'package:example/widgets/layout/layout.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  static const String routeName = '/about';

  @override
  Widget build(BuildContext context) {
    return const Layout(
      title: 'About ...',
      body: Text('body'),
    );
  }
}
