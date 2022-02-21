import 'package:fireflutter/src/admin/send.push.notification.service.dart';
import 'package:flutter/material.dart';

class SendPushNotification extends StatefulWidget {
  const SendPushNotification({Key? key}) : super(key: key);

  @override
  State<SendPushNotification> createState() => _SendPushNotificationState();
}

class _SendPushNotificationState extends State<SendPushNotification> {
  final tokens = TextEditingController();
  final topic = TextEditingController();
  final postId = TextEditingController();
  final title = TextEditingController();
  final content = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('tokens'),
        TextField(
          controller: tokens,
        ),
        const Text('topic'),
        TextField(
          controller: topic,
        ),
        const Text('postId'),
        TextField(
          controller: postId,
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
            SendPushNotificationService.instance.sendNotification();
          },
          child: Text('Send'),
        )
      ],
    );
  }
}
