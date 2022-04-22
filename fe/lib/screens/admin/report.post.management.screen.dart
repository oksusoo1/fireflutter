import 'package:extended/extended.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ReportPostManagementScreen extends StatelessWidget {
  const ReportPostManagementScreen({required this.arguments, Key? key})
      : super(key: key);

  static const String routeName = '/reportPostManagement';

  final Map arguments;
  String get target => arguments['target'];
  String get id => arguments['id'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Post Management'),
      ),
      body: ReportPostManagement(
        id: id,
        onError: error,
        builder: (post) {
          // print(target);
          return Column(
            children: [
              Text(post.content),
              Text(post.id),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await post.delete();
                        alert('Post deleted', 'You have deleted this post.');
                      } catch (e) {
                        error(e);
                      }
                    },
                    child: const Text('Delete'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // print('mark as resolve');
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
