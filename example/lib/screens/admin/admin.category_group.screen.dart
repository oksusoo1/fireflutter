import 'package:example/services/defines.dart';
import 'package:example/widgets/layout/layout.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class AdminCategoryGroupScreen extends StatelessWidget {
  const AdminCategoryGroupScreen({Key? key}) : super(key: key);

  static const String routeName = '/categoryGroup';

  @override
  Widget build(BuildContext context) {
    return Layout(
      backButton: true,
      title: Text(
        'Category Group Management',
        style: titleStyle,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CategoryGroupManagement(),
      ),
    );
  }
}
