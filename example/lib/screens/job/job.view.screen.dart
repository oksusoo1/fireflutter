import 'package:extended/extended.dart';
import 'package:fe/screens/forum/forum.mixin.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class JobViewScreen extends StatefulWidget {
  const JobViewScreen({required this.arguments, Key? key}) : super(key: key);
  static final String routeName = '/jobView';

  final Map arguments;

  @override
  State<JobViewScreen> createState() => _JobViewScreenState();
}

class _JobViewScreenState extends State<JobViewScreen>
    with FirestoreMixin, ForumMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.arguments['job'].companyName ?? ''),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            JobView(
              job: widget.arguments['job'],
            ),
            space2xl,
          ],
        ),
      )),
    );
  }
}
