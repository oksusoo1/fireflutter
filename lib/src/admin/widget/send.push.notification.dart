import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/admin/send.push.notification.service.dart';
import 'package:flutter/material.dart';

class SendPushNotification extends StatefulWidget {
  const SendPushNotification({Key? key, required this.onError})
      : super(key: key);

  final Function onError;

  @override
  State<SendPushNotification> createState() => _SendPushNotificationState();
}

class _SendPushNotificationState extends State<SendPushNotification> {
  final tokens = TextEditingController();
  final topic = TextEditingController();
  final uids = TextEditingController();
  final postId = TextEditingController();
  final title = TextEditingController();
  final content = TextEditingController();

  String dropdownValue = 'All';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton(
          items: <String>['All', 'Topic', 'Tokens', 'User Ids']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              dropdownValue = newValue!;
            });
          },
        ),
        if (dropdownValue == 'topic')
          Column(
            children: [
              const Text('topic'),
              TextField(
                controller: topic,
              ),
            ],
          ),
        if (dropdownValue == 'tokens')
          Column(
            children: [
              const Text('tokens'),
              TextField(
                controller: tokens,
              ),
            ],
          ),
        if (dropdownValue == 'User Ids')
          Column(
            children: [
              const Text('User Ids'),
              TextField(
                controller: uids,
              ),
            ],
          ),
        const Text('postId'),
        Column(
          children: [
            TextField(
              controller: postId,
            ),
            TextButton(
                onPressed: () async {
                  List<PostModel> posts =
                      await PostService.instance.get(uid: postId.text);
                  if (posts.isEmpty) widget.onError('Post not found');
                  title.text = posts[0].title;
                  content.text = posts[0].content;
                },
                child: Text('Load Post'))
          ],
        ),
        const Text('Title'),
        TextField(
          controller: title,
        ),
        const Text('Content'),
        TextField(
          controller: content,
        ),
        TextButton(
          onPressed: () {
            SendPushNotificationService.instance.sendNotification({
              'topic': topic.text,
              'token': tokens.text,
              'uids': uids.text,
              'id': postId,
              'title': title.text,
              'content': content.text,
            });
          },
          child: Text('Send'),
        )
      ],
    );
  }
}
