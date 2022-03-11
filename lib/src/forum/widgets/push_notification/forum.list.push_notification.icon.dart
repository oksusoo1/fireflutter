import '../../../../fireflutter.dart';

import './forum.list.push_notification.popup_button.dart';
import 'package:flutter/material.dart';

class ForumListPushNotificationIcon extends StatefulWidget {
  ForumListPushNotificationIcon(
    this.categoryId, {
    required this.onError,
    this.size,
    this.color,
  });
  final String categoryId;
  final double? size;
  final Function onError;
  final Color? color;
  @override
  _ForumListPushNotificationIconState createState() => _ForumListPushNotificationIconState();
}

class _ForumListPushNotificationIconState extends State<ForumListPushNotificationIcon> {
  bool loading = false;

  bool hasSubscription() {
    return UserService.instance.user.settings
            .hasSubscription(NotificationOptions.post(widget.categoryId)) ||
        UserService.instance.user.settings
            .hasSubscription(NotificationOptions.comment(widget.categoryId));
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
                            UserService.instance.user.settings
                                    .hasSubscription(NotificationOptions.post(widget.categoryId))
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
                              UserService.instance.user.settings.hasSubscription(
                                      NotificationOptions.comment(widget.categoryId))
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
                    hasSubscription() ? Icons.notifications : Icons.notifications_off,
                    color: widget.color,
                    size: widget.size,
                  ),
                  onSelected: onNotificationSelected,
                ),
                if (UserService.instance.user.settings
                    .hasSubscription(NotificationOptions.post(widget.categoryId)))
                  Positioned(
                    top: 15,
                    left: 5,
                    child: Icon(Icons.comment, size: 12, color: Colors.greenAccent),
                  ),
                if (UserService.instance.user.settings
                    .hasSubscription(NotificationOptions.comment(widget.categoryId)))
                  Positioned(
                    top: 15,
                    right: -2,
                    child: Icon(Icons.comment, size: 12, color: Colors.greenAccent),
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
      return showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('notifications'),
          content: Text('login_first'),
        ),
      );
    }

    // /// Show spinner
    setState(() => loading = true);
    String topic = '';
    String title = "notification";
    if (selection == 'post') {
      topic = NotificationOptions.post(widget.categoryId);
      title = 'post ' + title;
    } else if (selection == 'comment') {
      topic = NotificationOptions.comment(widget.categoryId);
      title = 'comment ' + title;
    }
    try {
      await MessagingService.instance.toggleSubscription(topic);
    } catch (e) {
      widget.onError(e);
    }

    /// Hide spinner
    setState(() => loading = false);
    String msg =
        UserService.instance.user.settings.hasSubscription(topic) ? 'subscribed' : 'unsubscribed';
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(widget.categoryId + " " + msg),
      ),
    );
  }
}

class NotificationOptions {
  static String notifyPost = 'posts_';
  static String notifyComment = 'comments_';

  static String post(String category) {
    return notifyPost + category;
  }

  static String comment(String category) {
    return notifyComment + category;
  }
}
