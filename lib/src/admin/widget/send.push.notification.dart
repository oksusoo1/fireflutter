import 'package:dio/dio.dart';

import '../../../fireflutter.dart';
import 'package:flutter/material.dart';

class SendPushNotification extends StatefulWidget {
  const SendPushNotification({Key? key, required this.onError})
      : super(key: key);

  final Function onError;

  @override
  State<SendPushNotification> createState() => _SendPushNotificationState();
}

class _SendPushNotificationState extends State<SendPushNotification> {
  final tokens = TextEditingController(
      text:
          'ecw_jCq6TV273wlDMeaQRY:APA91bF8GUuxtjlpBf7xI9M4dv6MD74rb40tpDedeoJ9w1TYi-9TmGCrt862Qcrj4nQifRBrxS60AiBSQW8ynYQFVj9Hkrd3p-w9UyDscLncNdwdZNXpqRgBR-LmSeZIcNBejvxjtfW4');
  final topic = TextEditingController(text: 'sendingToTestTopic');
  final uids = TextEditingController(text: 'sendMessaegUserB,sendMessaegUserA');
  final postId = TextEditingController(text: '0EWGGe64ckjBtiU1LeB1');
  final title = TextEditingController();
  final body = TextEditingController();

  String sendOption = 'all';
  Map<String, String> dropdownItem = {
    'all': 'All',
    'topic': 'Topic',
    'tokens': 'Tokens',
    'uids': 'Uids',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sending Option'),
          ListTile(
            title: DropdownButton(
              isExpanded: true,
              value: sendOption,
              items: dropdownItem.keys
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    dropdownItem[value]!,
                    style: TextStyle(),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  sendOption = newValue!;
                });
              },
            ),
          ),
          if (sendOption == 'topic')
            ListTile(
              leading: Text('Topic'),
              title: TextField(
                controller: topic,
              ),
            ),
          if (sendOption == 'tokens')
            ListTile(
              leading: Text('Tokens'),
              title: TextField(
                controller: tokens,
              ),
            ),
          if (sendOption == 'uids')
            ListTile(
              leading: Text('User Ids'),
              title: TextField(
                controller: uids,
              ),
            ),
          ListTile(
            leading: Text('postId'),
            title: TextField(
              controller: postId,
            ),
            trailing: TextButton(
              onPressed: () async {
                PostModel? post = await PostService.instance.load(postId.text);
                if (post == null) return widget.onError('Post not found');
                title.text = post.title;
                body.text = post.content;
              },
              child: Text('Load'),
            ),
          ),
          ListTile(
            leading: Text('Title'),
            title: TextField(
              controller: title,
            ),
          ),
          ListTile(
            leading: Text('Body'),
            title: TextField(
              controller: body,
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () => sendMessage(context),
              child: Text('Send Push Notification'),
            ),
          )
        ],
      ),
    );
  }

  sendMessage(context) async {
    Map<String, dynamic> req = {
      'title': title.text,
      'body': body.text,
    };
    if (postId.text.isNotEmpty) {
      req['data'] = {
        'id': postId.text,
        'type': 'post',
      };
    }

    try {
      Response<dynamic>? res;
      if (sendOption == 'all') {
        res = await SendPushNotificationService.instance.sendToAll(req);
      } else if (sendOption == 'topic') {
        req['topic'] = topic.text;
        res = await SendPushNotificationService.instance.sendToTopic(req);
      } else if (sendOption == 'tokens') {
        req['tokens'] = tokens.text;
        res = await SendPushNotificationService.instance.sendToToken(req);
      } else if (sendOption == 'uids') {
        req['uids'] = uids.text;
        res = await SendPushNotificationService.instance.sendToUsers(req);
      }

      Map<String, dynamic> data = res!.data;
      String msg = '';
      if (data['code'] == 'success') {
        if (sendOption == 'tokens' || sendOption == 'uids') {
          int s = data['result']['success'];
          int f = data['result']['error'];
          msg = "Send count $s Success, $f Fail.";
        } else if (data['result']['messageId'] != null) {
          msg = 'Push send Success';
        } else {
          msg = 'Push send didnt return proper data';
        }
      } else if (data['code'] == 'error') {
        msg = data['message'];
      }

      // print(msg);
      // return msg;
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Send Push Message'),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      widget.onError(e);
    }
  }
}
