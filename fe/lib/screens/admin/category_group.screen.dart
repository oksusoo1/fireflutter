// import 'package:extended/extended.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CategoryGroupScreen extends StatelessWidget {
  const CategoryGroupScreen({Key? key}) : super(key: key);

  static const String routeName = '/categoryGroup';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Group'),
      ),
      body: CategoryGroupManagement(),
    );
  }
}
