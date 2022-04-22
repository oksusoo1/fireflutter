import 'package:extended/extended.dart';
import 'package:fe/screens/chat/widgets/chat_room.message.dart';
import 'package:fe/screens/chat/widgets/chat_room.message_box.dart';
import 'package:fe/screens/friend_map/friend_map.screen.dart';
import 'package:fe/service/app.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({required this.arguments, Key? key}) : super(key: key);

  static const String routeName = '/chatRoom';
  final Map arguments;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: UserDoc(
          uid: widget.arguments['uid'],
          builder: (UserModel user) {
            return Text(user.displayName);
          },
        ),
      ),
      body: Auth(
          signedOut: () => const Text('login first'),
          signedIn: (u) {
            return ChatRoom(
              otherUid: widget.arguments['uid'],
              messageBuilder: (ChatMessageModel message) {
                /// If it's text, then display without popup menu for other user
                if (message.byOther && message.isText) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (message.isProtocol) {
                        if (message.text.contains('friendMap')) {
                          final arr = message.text.split(':').last.split(',');
                          AppService.instance.open(FriendMapScreen.routeName, arguments: {
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
                              onPressed: AppService.instance.back,
                              child: const Text('Close'),
                            ),
                            TextButton(
                              onPressed: () {
                                message
                                    .update(input.text)
                                    .then((x) => AppService.instance.back())
                                    .catchError((e) => error(e));
                              },
                              child: const Text('Update'),
                            ),
                          ],
                        ),
                      );
                    } else if (result == 'open') {
                      /// Uploaded files or link typed by user.
                      if (await canLaunch(message.text)) {
                        launch(message.text);
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
              onError: error,

              /// Send push notification here with no of new message.
              onUpdateOtherUserRoomInformation: (Map<String, dynamic> data) async {
                //          int newMessages = 0;

                /// Send push notification to the other user.
                // QuerySnapshot querySnapshot = await ChatService.instance
                //     .otherUserRoomsCol(otherUid)
                //     .where('newMessages', isGreaterThan: 0)
                //     .get();

                // newMessages = 0;
                // querySnapshot.docs.forEach((doc) {
                //   ChatDataModel room = ChatDataModel.fromJson(doc.data() as Map);
                //   newMessages += room.newMessages;
                // });

                // // sent message to other user.
                // MessagingApi.instance.sendMessageToUsers(
                //   title: UserApi.instance.currentUser.displayName + ' sent a message',
                //   content: data['text'], // for image "Sent a photo"
                //   ids: [other!.id],
                //   badge: newMessages,
                //   // chat subscription to disable chat message notification
                //   // this doesnt subscribe to topic but check if the user has meta that is set to 'off' value
                //   subscription: 'chatNotify' + UserApi.instance.currentUser.userLogin,
                //   data: {
                //     'type': 'chat',
                //     'otherUid': UserApi.instance.currentUser.userLogin,
                //   },
                // );
              },
              emptyDisplay: Text('Chat room is empty for ${widget.arguments['uid']}'),
            );
          }),
    );
  }
}
