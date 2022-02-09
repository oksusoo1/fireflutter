import 'package:fireflutter/fireflutter.dart';

import './forum.list.push_notification.popup_button.dart';
import 'package:flutter/material.dart';

class ForumListPushNotificationIcon extends StatefulWidget {
  ForumListPushNotificationIcon(
    this.categoryId, {
    required this.onError,
    this.size,
  });
  final String categoryId;
  final double? size;
  final Function onError;
  @override
  _ForumListPushNotificationIconState createState() =>
      _ForumListPushNotificationIconState();
}

class _ForumListPushNotificationIconState
    extends State<ForumListPushNotificationIcon> {
  bool loading = false;

  @override
  void initState() {
    super.initState();

    initForumListPushNotificationIcons();
  }

  initForumListPushNotificationIcons() {
    if (widget.categoryId == '') return;
    // setState(() => loading = true);

    // /// Get latest user's profile from backend
    // if (UserService.instance.user.signedIn) {
    //   setState(() => loading = false);
    // } else {
    //   setState(() => loading = false);
    // }
  }

  bool hasSubscription() {
    return UserService.instance.user
            .hasSubscriptions(NotificationOptions.post(widget.categoryId)) ||
        UserService.instance.user
            .hasSubscriptions(NotificationOptions.comment(widget.categoryId));
  }

  @override
  Widget build(BuildContext context) {
    return widget.categoryId != ''
        ? Container(
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                ForumListPushNotificationPopUpButton(
                  items: [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            UserService.instance.user.hasSubscriptions(
                                    NotificationOptions.post(widget.categoryId))
                                ? Icons.notifications_on
                                : Icons.notifications_off,
                            color: Colors.blue,
                          ),
                          Text('post' + " " + widget.categoryId),
                        ],
                      ),
                      value: 'post',
                    ),
                    PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(
                              UserService.instance.user.hasSubscriptions(
                                      NotificationOptions.comment(
                                          widget.categoryId))
                                  ? Icons.notifications_on
                                  : Icons.notifications_off,
                              color: Colors.blue,
                            ),
                            Text('comment' + " " + widget.categoryId),
                          ],
                        ),
                        value: 'comment'),
                  ],
                  icon: Icon(
                    hasSubscription()
                        ? Icons.notifications
                        : Icons.notifications_off,
                    color: Colors.white,
                    size: widget.size,
                  ),
                  onSelected: onNotificationSelected,
                ),
                if (UserService.instance.user.hasSubscriptions(
                    NotificationOptions.post(widget.categoryId)))
                  Positioned(
                    top: 15,
                    left: 5,
                    child: Icon(Icons.comment,
                        size: 12, color: Colors.greenAccent),
                  ),
                if (UserService.instance.user.hasSubscriptions(
                    NotificationOptions.comment(widget.categoryId)))
                  Positioned(
                    top: 15,
                    right: 5,
                    child: Icon(Icons.comment,
                        size: 12, color: Colors.greenAccent),
                  ),
                if (loading)
                  Positioned(
                    bottom: 15,
                    left: 10,
                    child: SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          )
        : SizedBox.shrink();
  }

  onNotificationSelected(dynamic selection) async {
    if (UserService.instance.user.signedOut) {
      return AlertDialog(
        title: Text('notifications'),
        content: Text('login_first'),
      );
    }

    // /// Show spinner
    setState(() => loading = true);
    String topic = '';
    String title = "notification";
    if (selection == 'post') {
      topic = NotificationOptions.post(widget.categoryId);
      title = 'post_' + title;
    } else if (selection == 'comment') {
      topic = NotificationOptions.comment(widget.categoryId);
      title = 'comment_' + title;
    }
    try {
      await MessagingService.instance.updateSubscription(topic);
    } catch (e) {
      widget.onError(e);
    }

    /// Hide spinner
    setState(() => loading = false);
    String msg = UserService.instance.user.hasSubscriptions(topic)
        ? 'subscribed'
        : 'unsubscribed';
    AlertDialog(
      title: Text(title),
      content: Text(msg),
    );
  }
}

class NotificationOptions {
  static String notifyPost = 'notifyPost_';
  static String notifyComment = 'notifyComment_';

  static String post(String category) {
    return notifyPost + category;
  }

  static String comment(String category) {
    return notifyComment + category;
  }
}
