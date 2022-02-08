import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/forum/widgets/push_notification/forum.list.push_notification.popup_button.dart';
import 'package:flutter/material.dart';

class ForumListPushNotificationIcon extends StatefulWidget {
  ForumListPushNotificationIcon(this.categoryId, {this.size});
  final String categoryId;
  final double? size;
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
    //   UserService.instance.profile().then((profile) {
    //     setState(() => loading = false);
    //   });
    // } else {
    //   setState(() => loading = false);
    // }
  }

  bool hasSubscription() {
    return false;
    // return UserApi.instance.currentUser
    //         .hasSubscriptions(NotificationOptions.post(widget.categoryId)) ||
    //     UserApi.instance.currentUser
    //         .hasSubscriptions(NotificationOptions.comment(widget.categoryId));
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
                          // UserApi.instance.currentUser.hasSubscriptions(
                          //         NotificationOptions.post(widget.categoryId))
                          //     ? Icons.notifications_on
                          //     :
                          Icons.notifications_off,
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
                            // UserApi.instance.currentUser.hasSubscriptions(
                            //         NotificationOptions.comment(
                            //             widget.categoryId))
                            //     ? Icons.notifications_on
                            //     :
                            Icons.notifications_off,
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
                  color: Colors.blue,
                  size: widget.size,
                ),
                onSelected: onNotificationSelected,
              ),
              // if (UserApi.instance.currentUser.hasSubscriptions(
              //     NotificationOptions.post(widget.categoryId)))
              Positioned(
                top: 15,
                left: 5,
                child: Icon(Icons.comment, size: 12, color: Colors.greenAccent),
              ),
              // if (UserApi.instance.currentUser.hasSubscriptions(
              //     NotificationOptions.comment(widget.categoryId)))
              Positioned(
                top: 15,
                right: 5,
                child: Icon(Icons.comment, size: 12, color: Colors.greenAccent),
              ),
              if (loading)
                Positioned(
                    bottom: 15, left: 10, child: CircularProgressIndicator()
                    // Spinner(
                    //   size: 10,
                    // ),
                    ),
            ],
          ))
        : SizedBox.shrink();
  }

  onNotificationSelected(dynamic selection) async {
    // if (UserApi.instance.currentUser.notLoggedIn) {
    //   return Get.snackbar('notifications'.tr, 'login_first'.tr);
    // }

    // /// Show spinner
    // setState(() => loading = true);
    // String topic = '';
    // String title = "notification";
    // if (selection == 'post') {
    //   topic = NotificationOptions.post(widget.categoryId);
    //   title = 'post_' + title;
    // } else if (selection == 'comment') {
    //   topic = NotificationOptions.comment(widget.categoryId);
    //   title = 'comment_' + title;
    // }
    // try {
    //   await MessagingApi.instance.updateSubscription(topic);
    //   await UserApi.instance.profile();
    // } catch (e) {
    //   service.error(e);
    // }

    // /// Hide spinner
    // setState(() => loading = false);
    // String msg = UserApi.instance.currentUser.hasSubscriptions(topic)
    //     ? 'subscribed'
    //     : 'unsubscribed';
    // Get.snackbar(title.tr, msg.tr);
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
