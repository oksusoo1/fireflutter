import '../../../../fireflutter.dart';

import './forum.list.push_notification.popup_button.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math; // import this

class ForumListPushNotificationIcon extends StatefulWidget {
  ForumListPushNotificationIcon(
    this.categoryId, {
    required this.onError,
    required this.onSigninRequired,
    required this.onChanged,
    this.size,
  });
  final String categoryId;
  final double? size;
  final Function onError;
  final Function onSigninRequired;
  final Function(String, bool) onChanged;
  @override
  _ForumListPushNotificationIconState createState() =>
      _ForumListPushNotificationIconState();
}

class _ForumListPushNotificationIconState
    extends State<ForumListPushNotificationIcon> {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${widget.categoryId} Subscriptions',
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Divider(),
                      Row(
                        children: [
                          Icon(
                            hasPostSubscription
                                ? Icons.notifications_on
                                : Icons.notifications_off,
                            color:
                                hasPostSubscription ? Colors.blue : Colors.grey,
                          ),
                          Text(
                            ' Post' + " " + widget.categoryId,
                            style: TextStyle(
                              color: hasPostSubscription
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  value: 'post',
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(
                        hasCommentSubscription
                            ? Icons.notifications_on
                            : Icons.notifications_off,
                        color:
                            hasCommentSubscription ? Colors.blue : Colors.grey,
                      ),
                      Text(
                        ' Comment' + " " + widget.categoryId,
                        style: TextStyle(
                          color: hasCommentSubscription
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  value: 'comment',
                ),
              ],
              icon: Icon(
                hasSubscription
                    ? Icons.notifications_on
                    : Icons.notifications_off,
                color: hasSubscription
                    ? Color.fromARGB(255, 74, 74, 74)
                    : Color.fromARGB(255, 177, 177, 177),
                size: widget.size,
              ),
              onSelected: onNotificationSelected,
            ),
            if (hasPostSubscription)
              Positioned(
                top: 20,
                left: 15,
                child: Transform(
                  transform: Matrix4.rotationY(math.pi),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.circle,
                    size: 6,
                    color: Color.fromARGB(255, 196, 255, 239),
                  ),
                ),
              ),
            if (hasCommentSubscription)
              Positioned(
                top: 20,
                right: 5,
                child: Icon(
                  Icons.circle,
                  size: 6,
                  color: Color.fromARGB(255, 255, 202, 132),
                ),
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

    return widget.onChanged(
      selection,
      UserService.instance.user.settings.hasSubscription(topic),
    );

    // String msg =
    //     UserService.instance.user.settings.hasSubscription(topic) ? 'subscribed' : 'unsubscribed';

    // showDialog(
    //   context: context,
    //   builder: (c) => AlertDialog(
    //     title: Text(title),
    //     content: Text(widget.categoryId + " " + msg),
    //   ),
    // );
  }
}
