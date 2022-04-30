import 'package:example/services/defines.dart';
import 'package:example/services/global.dart';
import 'package:example/widgets/layout/layout.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class AdminCategoryScreen extends StatelessWidget {
  const AdminCategoryScreen({Key? key}) : super(key: key);

  static const String routeName = '/category';

  @override
  Widget build(BuildContext context) {
    return Layout(
      backButton: true,
      title: const Text('Category Management', style: titleStyle),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CategoryManagement(
          onCreate: () => service.alert('Category Create', 'Category had been created'),
          onError: service.error,
        ),
      ),
    );
  }
}
