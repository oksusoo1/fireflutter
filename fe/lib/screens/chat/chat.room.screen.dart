import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended/extended.dart';
import 'package:fe/screens/chat/widgets/chat_room.message.dart';
import 'package:fe/screens/chat/widgets/chat_room.message_box.dart';
import 'package:fe/screens/friend_map/friend_map.screen.dart';
import 'package:fe/services/app.service.dart';
import 'package:fe/services/defines.dart';
import 'package:fe/services/global.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatRoomScreen extends StatelessWidget {
  const ChatRoomScreen({required this.arguments, Key? key}) : super(key: key);

  static const String routeName = '/chatRoom';
  final Map arguments;

  String get otherUid => arguments['uid'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        title: UserDoc(
          uid: otherUid,
          builder: (UserModel user) {
            return Text(user.displayName, style: titleStyle);
          },
        ),
        actions: [
          ChatRoomPushNotificationIcon(
            otherUid,
            size: 28,
          ),
          UserDoc(
              uid: otherUid,
              builder: (user) {
                return StreamBuilder<DocumentSnapshot>(
                    stream: ChatService.instance.myRoomsBlockedCol.doc(otherUid).snapshots(),
                    builder: (c, snapshot) {
                      if (snapshot.hasData == false) return SizedBox();
                      final snapshotDoc = snapshot.data!;
                      bool _blocked = snapshotDoc.exists;

                      return Popup(
                        icon: Icon(
                          Icons.settings,
                          color: Colors.black,
                        ),
                        initialValue: '',
                        options: {
                          'friendMap':
                              PopupOption(icon: const Icon(Icons.map), label: 'Friend Map'),
                          if (_blocked)
                            'unblock': PopupOption(icon: Icon(Icons.block), label: 'Unblock'),
                          if (!_blocked)
                            'block': PopupOption(icon: Icon(Icons.block), label: 'Block'),
                          'report': PopupOption(icon: Icon(Icons.report), label: 'Report'),
                          'close': PopupOption(icon: Icon(Icons.close), label: 'Close'),
                        },
                        onSelected: (v) async {
                          if (v == 'friendMap') {
                            // service.requestFriendMap(user);
                            alert('@todo - friend map', 'friend map todo');
                          } else if (v == 'block') {
                            final re =
                                await service.confirm('Block', 'Do you want to block this user?');
                            if (re == false) return;
                            // block user
                            ChatService.instance.blockUser(otherUid);
                            service.router.back();
                          } else if (v == 'unblock') {
                            final re =
                                await service.confirm('Block', 'Do you want to unblock this user?');
                            if (re == false) return;
                            // block user
                            ChatService.instance.unblockUser(otherUid);
                            service.router.back();
                          } else if (v == 'report') {
                            String? re = await inputDialog('Report User', 'Reason');
                            if (re == null) return;
                            // save report to backend
                            await ReportApi.instance.report(
                              target: 'chat',
                              targetId: getChatRoomDocumentId(UserService.instance.uid, otherUid),
                              reason: re,
                            );
                            service.alert(
                                'Reported', 'You have been reported this user successfully.');
                          }
                        },
                      );
                    });
              }),
        ],
      ),
      body: Auth(
        signedOut: () => const Text('login first'),
        signedIn: (u) {
          return ChatRoom(
            otherUid: otherUid,
            messageBuilder: (ChatMessageModel message) {
              /// If it's text, then display without popup menu for other user
              if (message.byOther && message.isText) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (message.isProtocol) {
                      if (message.text.contains('friendMap')) {
                        final arr = message.text.split(':').last.split(',');
                        AppService.instance
                          ..router.open(FriendMapScreen.routeName, arguments: {
                            'latitude': arr.first.trim(),
                            'longitude': arr.last.trim(),
                          });
                      }
                    }
                  },
                  child: ChatRoomMessage(message),
                );
              }
              return PopupMenuButton<String>(
                offset: message.isMine ? const Offset(1, 50) : const Offset(0, 50),
                child: ChatRoomMessage(message),
                onSelected: (String result) async {
                  if (result == 'delete') {
                    final re =
                        await confirm('Message delete', 'Do you want to delete this message?');
                    if (re == false) return;
                    message.delete().catchError((e) => error(e));
                  } else if (result == 'edit') {
                    final input = TextEditingController(text: message.text);
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Edit message'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: input,
                              maxLines: 4,
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: AppService.instance.router.back,
                            child: const Text('Close'),
                          ),
                          TextButton(
                            onPressed: () {
                              message
                                  .update(input.text)
                                  .then((x) => AppService.instance.router.back())
                                  .catchError((e) => error(e));
                            },
                            child: const Text('Update'),
                          ),
                        ],
                      ),
                    );
                  } else if (result == 'open') {
                    /// Uploaded files or link typed by user.
                    if (await canLaunchUrl(Uri.parse(message.text))) {
                      launchUrl(Uri.parse(message.text));
                    } else {
                      error('Cannot launch ${message.text}');
                    }
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  if (message.isMine && message.isImage == false)
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                  if (message.isMine)
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),

                  /// Uploaded files or link typed by user.
                  if (message.isUrl)
                    const PopupMenuItem<String>(
                      value: 'open',
                      child: Text('Open'),
                    ),
                ],
              );
            },

            inputBuilder: (onSubmit) => ChatRoomMessageBox(onSend: onSubmit),
            // onError: error,

            /// Send push notification here with no of new message.
            onUpdateOtherUserRoomInformation: (Map<String, dynamic> data) async {
              ///
            },
            emptyDisplay: Text('Chat room is empty for $otherUid'),
          );
        },
      ),
    );
  }
}
