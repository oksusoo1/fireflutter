import 'package:extended/extended.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  static const String routeName = '/category';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Management'),
      ),
      body: CategoryManagement(
        onCreate: () => alert('Category Create', 'Category had been created'),
        onError: error,
      ),
    );
  }
}
