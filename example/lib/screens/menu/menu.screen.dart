import 'package:example/widgets/layout/layout.dart';
import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  static const String routeName = '/menu';

  @override
  Widget build(BuildContext context) {
    return const Layout(
      title: Text(
        'Menu ...',
        style: TextStyle(color: Colors.blue),
      ),
      body: Text('body'),
    );
  }
}
