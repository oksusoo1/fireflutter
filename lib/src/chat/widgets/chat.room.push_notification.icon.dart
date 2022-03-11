import '../../../fireflutter.dart';

import 'package:flutter/material.dart';

class ChatRoomPushNotificationIcon extends StatefulWidget {
  ChatRoomPushNotificationIcon(
    this.uid, {
    required this.onError,
    this.size,
  });
  final String uid;
  final double? size;
  final Function onError;
  @override
  _ChatRoomPushNotificationIconState createState() => _ChatRoomPushNotificationIconState();
}

class _ChatRoomPushNotificationIconState extends State<ChatRoomPushNotificationIcon> {
  bool hasSubscription() {
    return UserService.instance.user.settings.hasSubscription('chatNotify' + widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return widget.uid != ''
        ? GestureDetector(
            child: Icon(
              hasSubscription() ? Icons.notifications : Icons.notifications_off,
              color: Colors.black,
              size: widget.size,
            ),
            onTap: () => toggle(),
          )
        : SizedBox.shrink();
  }

  toggle() async {
    if (UserService.instance.user.signedOut) {
      return showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('notifications'),
          content: Text('login_first'),
        ),
      );
    }

    try {
      await MessagingService.instance.toggleSubscription('chatNotify' + widget.uid);
      if (mounted) setState(() {});
    } catch (e) {
      widget.onError(e);
    }
    String msg = UserService.instance.user.settings.hasSubscription('chatNotify' + widget.uid)
        ? 'subscribed'
        : 'unsubscribed';
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Notification'),
        content: Text(msg),
      ),
    );
  }
}
