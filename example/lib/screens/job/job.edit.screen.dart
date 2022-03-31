import 'package:extended/extended.dart';
import 'package:fe/screens/forum/forum.mixin.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class JobEditScreen extends StatefulWidget {
  const JobEditScreen({required this.arguments, Key? key}) : super(key: key);
  static final String routeName = '/jobEdit';

  final Map arguments;

  @override
  State<JobEditScreen> createState() => _JobEditScreenState();
}

class _JobEditScreenState extends State<JobEditScreen> with FirestoreMixin, ForumMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Edit'),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          JobEditForm(
            onError: error,
          ),
          space2xl,
        ],
      )),
    );
  }
}
