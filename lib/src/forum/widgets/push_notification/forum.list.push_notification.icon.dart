import '../../../../fireflutter.dart';

import './forum.list.push_notification.popup_button.dart';
import 'package:flutter/material.dart';

class ForumListPushNotificationIcon extends StatefulWidget {
  ForumListPushNotificationIcon(
    this.categoryId, {
    required this.onError,
    required this.onSigninRequired,
    this.size,
    this.color,
  });
  final String categoryId;
  final double? size;
  final Function onError;
  final Function onSigninRequired;
  final Color? color;
  @override
  _ForumListPushNotificationIconState createState() => _ForumListPushNotificationIconState();
}

class _ForumListPushNotificationIconState extends State<ForumListPushNotificationIcon> {
  bool get hasSubscription {
    return UserService.instance.user.settings
            .hasSubscription(NotificationOptions.post(widget.categoryId)) ||
        UserService.instance.user.settings
            .hasSubscription(NotificationOptions.comment(widget.categoryId));
  }

  bool get hasPostSubscription {
    return UserService.instance.user.settings
        .hasSubscription(NotificationOptions.post(widget.categoryId));
  }

  bool get hasCommentSubscription {
    return UserService.instance.user.settings
        .hasSubscription(NotificationOptions.comment(widget.categoryId));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categoryId == '') return SizedBox.shrink();

    return UserSettingDoc(
      builder: (settings) {
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            ForumListPushNotificationPopUpButton(
              items: [
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(
                        hasPostSubscription ? Icons.notifications_on : Icons.notifications_off,
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
                          hasCommentSubscription ? Icons.notifications_on : Icons.notifications_off,
                          color: Colors.blue,
                        ),
                        Text('comment' + " " + widget.categoryId),
                      ],
                    ),
                    value: 'comment'),
              ],
              icon: Icon(
                hasSubscription ? Icons.notifications : Icons.notifications_off,
                color: widget.color,
                size: widget.size,
              ),
              onSelected: onNotificationSelected,
            ),
            if (hasPostSubscription)
              Positioned(
                top: 15,
                left: 5,
                child: Icon(Icons.comment, size: 12, color: Colors.greenAccent),
              ),
            if (hasCommentSubscription)
              Positioned(
                top: 15,
                right: -2,
                child: Icon(Icons.comment, size: 12, color: Colors.greenAccent),
              ),
          ],
        );
      },
    );
  }

  onNotificationSelected(dynamic selection) async {
    if (UserService.instance.user.signedOut) {
      widget.onSigninRequired();
      return;
      // return showDialog(
      //   context: context,
      //   builder: (c) => AlertDialog(
      //     title: Text('Notifications'),
      //     content: Text('Please, sign in first...'),
      //   ),
      // );
    }

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
