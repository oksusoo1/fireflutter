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
  final tokens = TextEditingController();
  final topic = TextEditingController();
  final uids = TextEditingController();
  final postId = TextEditingController();
  final title = TextEditingController();
  final body = TextEditingController();

  String dropdownValue = 'All';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sending Option'),
          DropdownButton(
            isExpanded: true,
            value: dropdownValue,
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
          if (dropdownValue == 'Topic')
            ListTile(
              leading: Text('Topic'),
              title: TextField(
                controller: topic,
              ),
            ),
          if (dropdownValue == 'Tokens')
            ListTile(
              leading: Text('Tokens'),
              title: TextField(
                controller: tokens,
              ),
            ),
          if (dropdownValue == 'User Ids')
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
                List<PostModel> posts =
                    await PostService.instance.get(uid: postId.text);
                if (posts.isEmpty) widget.onError('Post not found');
                title.text = posts[0].title;
                body.text = posts[0].content;
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
          TextButton(
            onPressed: () {
              Map<String, dynamic> data = {
                'title': title.text,
                'body': body.text,
              };
              if (postId.text.isNotEmpty) {
                data['data'] = {
                  'id': postId.text,
                  'type': 'post',
                };
              }
            },
            child: Text('Send'),
          )
        ],
      ),
    );
  }
}
