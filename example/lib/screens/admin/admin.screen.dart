import 'package:example/services/global.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:example/widgets/layout/layout.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  static const String routeName = '/admin';

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();
    UserService.instance.updateAdminStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: Text(
        'Admin Screen',
        style: TextStyle(color: Colors.blue),
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: service.router.openAdminCategory,
            child: Text('Category Management'),
          ),
          TextButton(
            onPressed: service.router.openAdminCategoryGroup,
            child: Text('Category Group Management'),
          ),
        ],
      ),
    );
  }
}
