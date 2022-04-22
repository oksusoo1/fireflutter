import '../../../fireflutter.dart';
import 'package:flutter/material.dart';

class SendPushNotification extends StatefulWidget {
  const SendPushNotification({Key? key, required this.onError, this.arguments})
      : super(key: key);

  final Function onError;
  final Map? arguments;

  @override
  State<SendPushNotification> createState() => _SendPushNotificationState();
}

class _SendPushNotificationState extends State<SendPushNotification> {
  final tokens = TextEditingController();
  final topic = TextEditingController();
  final uids = TextEditingController();
  final postId = TextEditingController();
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
  void initState() {
    super.initState();

    // print(widget.arguments);
    if (widget.arguments != null) {
      if (widget.arguments!['tokens'] != null) {
        tokens.text = widget.arguments!['tokens'];
        sendOption = 'tokens';
      } else if (widget.arguments!['topic'] != null) {
        topic.text = widget.arguments!['topic'];
        sendOption = 'topic';
      } else if (widget.arguments!['uids'] != null) {
        uids.text = widget.arguments!['uids'];
        sendOption = 'uids';
      }

      if (widget.arguments!['postId'] != null) {
        postId.text = widget.arguments!['postId'];
        loadPost();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            subtitle: Text('Select receiver'),
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
              onPressed: () => loadPost(),
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

  loadPost() async {
    if (postId.text.isEmpty) return;
    PostModel? post = await PostService.instance.load(postId.text);
    if (post == null) return widget.onError('Post not found');
    title.text = post.title;
    body.text = post.content;
  }

  sendMessage(context) async {
    Map<String, dynamic> req = {
      'title': title.text,
      'body': body.text,
    };
    if (postId.text.isNotEmpty) {
      req['id'] = postId.text;
      req['type'] = 'post';
    }

    try {
      Map<String, dynamic> data = {};

      if (sendOption == 'all') {
        data = await SendPushNotificationService.instance.sendToAll(req);
      } else if (sendOption == 'topic') {
        req['topic'] = topic.text;
        data = await SendPushNotificationService.instance.sendToTopic(req);
      } else if (sendOption == 'tokens') {
        req['tokens'] = tokens.text;
        data = await SendPushNotificationService.instance.sendToToken(req);
      } else if (sendOption == 'uids') {
        req['uids'] = uids.text;
        data = await SendPushNotificationService.instance.sendToUsers(req);
      }

      String msg = '';
      if (data['code'] == null) {
        if (sendOption == 'tokens' || sendOption == 'uids') {
          int s = data['success'];
          int f = data['error'];
          msg = "Send count $s Success, $f Fail.";
        } else if (data['messageId'] != null) {
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
