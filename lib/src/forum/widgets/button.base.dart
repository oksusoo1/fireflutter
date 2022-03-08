import 'package:flutter/material.dart';
import '../../../fireflutter.dart';

class ButtonBase extends StatelessWidget {
  const ButtonBase({
    required this.uid,
    required this.isPost,
    required this.onReply,
    required this.onReport,
    required this.onEdit,
    required this.onDelete,
    required this.onLike,
    this.onDislike,
    this.onChat,
    this.onHide,
    this.likeCount = 0,
    this.dislikeCount = 0,
    required this.buttonBuilder,
    this.shareButton,
    this.onSendPushNotification,
    this.onBlockUser,
    Key? key,
  }) : super(key: key);

  final String uid;
  final bool isPost;
  final Function() onReply;
  final Function() onReport;
  final Function() onEdit;
  final Function() onDelete;
  final Function() onLike;
  final Function()? onDislike;
  final Function()? onChat;
  final Function()? onHide;
  final Widget? shareButton;
  final Function()? onSendPushNotification;
  final Function()? onBlockUser;

  final Widget Function(String, Function())? buttonBuilder;

  bool get isMine {
    return UserService.instance.currentUser?.uid == uid;
  }

  bool get isAdmin {
    return UserService.instance.user.isAdmin;
  }

  final int likeCount;
  final int dislikeCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _button(isPost ? 'Reply' : 'Reply', onReply),
        _button('Report', onReport),
        _button('Like ${likeCount > 0 ? likeCount : ""}', onLike),
        if (onDislike != null)
          _button(
              'Dislike ${dislikeCount > 0 ? dislikeCount : ""}', onDislike!),
        if (!isMine && onChat != null) _button('Chat', onChat!),
        if (shareButton != null) shareButton!,
        Spacer(),
        PopupMenuButton<String>(
          child: Padding(
            padding: EdgeInsets.only(right: 2),
            child: Icon(Icons.more_vert),
          ),
          initialValue: '',
          itemBuilder: (BuildContext context) => [
            if (isMine)
              PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
            if (isMine || isAdmin)
              PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            if (isAdmin && onBlockUser != null)
              PopupMenuItem<String>(
                value: 'block',
                child: Text('Block User', style: TextStyle(color: Colors.red)),
              ),
            PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'report',
              child: Text('Report', style: TextStyle(color: Colors.red)),
            ),
            if (isAdmin && onSendPushNotification != null)
              PopupMenuItem<String>(
                value: 'notification',
                child: Text(
                  'Send push notification',
                ),
              ),
            if (isPost && onHide != null)
              PopupMenuItem<String>(
                  value: 'hide_post', child: Text('Hide Post')),
            PopupMenuItem<String>(value: 'close_menu', child: Text('Close')),
          ],
          onSelected: (String value) async {
            if (value == 'hide_post') {
              onHide!();
              return;
            }

            if (value == 'report') {
              onReport();
              return;
            }
            if (value == 'edit') {
              onEdit();
              return;
            }
            if (value == 'delete') {
              onDelete();
              return;
            }

            if (value == 'notification') {
              onSendPushNotification!();
              return;
            }

            if (value == 'block') {
              onBlockUser!();
              return;
            }
          },
        )
      ],
    );
  }

  Widget _button(String label, Function() callback) {
    return buttonBuilder != null
        ? buttonBuilder!(label, callback)
        : TextButton(
            onPressed: callback,
            child: Text(
              label,
              style: TextStyle(color: Colors.black, fontSize: 12),
            ),
          );
  }
}
