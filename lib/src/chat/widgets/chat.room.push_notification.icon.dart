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
  _ChatRoomPushNotificationIconState createState() =>
      _ChatRoomPushNotificationIconState();
}

class _ChatRoomPushNotificationIconState
    extends State<ChatRoomPushNotificationIcon> {
  bool hasDisabledSubscription() {
    return UserService.instance.user.settings
        .hasDisabledSubscription('chatNotify' + widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return widget.uid != ''
        ? GestureDetector(
            child: Icon(
              hasDisabledSubscription()
                  ? Icons.notifications_off
                  : Icons.notifications,
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
      // await MessagingService.instance.toggleSubscription('chatNotify' + widget.uid);
      await MessagingService.instance.updateSubscription(
        'chatNotify' + widget.uid,
        hasDisabledSubscription(),
      );
      if (mounted) setState(() {});
    } catch (e) {
      widget.onError(e);
    }
    String msg = hasDisabledSubscription() ? 'unsubscribed' : 'subscribed';
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Notification'),
        content: Text(msg),
      ),
    );
  }
}
