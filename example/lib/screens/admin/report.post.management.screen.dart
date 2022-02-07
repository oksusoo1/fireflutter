import 'package:extended/extended.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportPostManagementScreen extends StatelessWidget {
  const ReportPostManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String target = Get.arguments['target'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Post Management'),
      ),
      body: ReportPostManagement(
        id: Get.arguments['id'],
        onError: error,
        builder: (PostModel post) {
          print(target);
          return Column(
            children: [
              Text(post.content),
              Text(post.id),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      print('mark as deleted');
                    },
                    child: const Text('Delete'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      print('mark as resolve');
                    },
                    child: const Text('Resolve'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
