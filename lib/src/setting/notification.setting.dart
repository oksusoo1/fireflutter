import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterfire_ui/firestore.dart';

import '../../fireflutter.dart';
import 'package:flutter/material.dart';

class NotificationSetting extends StatefulWidget {
  const NotificationSetting({
    Key? key,
    required this.onError,
  }) : super(key: key);
  final Function onError;

  @override
  _NotificationSettingState createState() => _NotificationSettingState();
}

class _NotificationSettingState extends State<NotificationSetting>
    with FirestoreMixin {
  Map<String, bool> posts = {};
  Map<String, bool> comments = {};

  bool loading = false;

  @override
  void initState() {
    super.initState();

    () async {
      loading = true;
      try {
        final res = await categoryCol.orderBy('title').get();

        for (DocumentSnapshot doc in res.docs) {
          Map<String, dynamic> c = doc.data() as Map<String, dynamic>;
          if (UserService.instance.user
              .hasSubscription('posts_' + c['title'])) {
            posts[c['title']] = true;
          } else {
            posts[c['title']] = false;
          }

          if (UserService.instance.user
              .hasSubscription('comments_' + c['title'])) {
            comments[c['title']] = true;
          } else {
            comments[c['title']] = false;
          }
        }
        loading = false;
        setState(() {});
      } catch (e) {
        widget.onError(e);
        loading = false;

        setState(() {});
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Center(child: CircularProgressIndicator.adaptive());
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            print('Enable all notification');
          },
          child: Text('Enable all notification'),
        ),
        ElevatedButton(
          onPressed: () {
            print('Disable all notification');
          },
          child: Text('Disable all notification'),
        ),
        Text('Post notification'),
        for (String n in posts.keys)
          ListTile(
            leading: IconButton(
              icon: posts[n] == true
                  ? Icon(Icons.check_box)
                  : Icon(Icons.check_box_outline_blank),
              onPressed: () async {
                // save changes
                if (mounted)
                  try {
                    await MessagingService.instance
                        .updateSubscription('posts_' + n);
                    setState(() {
                      posts[n] = !posts[n]!;
                    });
                  } catch (e) {
                    widget.onError(e);
                  }
              },
            ),
            title: Text(n),
          ),
        Text('Comment notification'),
        for (String n in comments.keys)
          ListTile(
            leading: IconButton(
              icon: comments[n] == true
                  ? Icon(Icons.check_box)
                  : Icon(Icons.check_box_outline_blank),
              onPressed: () async {
                // save changes
                if (mounted)
                  try {
                    await MessagingService.instance
                        .updateSubscription('comments_' + n);
                    setState(() {
                      comments[n] = !comments[n]!;
                    });
                  } catch (e) {
                    widget.onError(e);
                  }
              },
            ),
            title: Text(n),
          ),
      ],
    );
  }
}
