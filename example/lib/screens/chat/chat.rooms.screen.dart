import 'package:fe/screens/chat/widgets/chat.rooms.dart';
import 'package:fe/screens/chat/widgets/chat.rooms.empty.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:extended/extended.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRoomsScreen extends StatelessWidget {
  const ChatRoomsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Room List')),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator.adaptive();
          }
          if (snapshot.hasData) {
            return ChatRooms(
              itemBuilder: (room) => ChatRoomsUser(room),
              emptyDisplay: ChatRoomsEmpty(),
            );
          } else {
            return ChatRoomsEmpty();
          }
        },
      ),
    );
  }
}

class ChatRoomsUser extends StatefulWidget {
  const ChatRoomsUser(this.room, {Key? key}) : super(key: key);

  final ChatMessageModel room;
  @override
  State<ChatRoomsUser> createState() => _ChatRoomsUserState();
}

class _ChatRoomsUserState extends State<ChatRoomsUser> {
  ChatMessageModel get room => widget.room;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return UserDoc(
      uid: widget.room.otherUid,
      builder: (UserModel user) {
        return GestureDetector(
          onTap: () => Get.toNamed('/chat-room-screen',
              arguments: {'uid': widget.room.otherUid}),
          child: Container(
            margin: const EdgeInsets.all(xs),
            padding: const EdgeInsets.all(xs),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(sm)),
              color: room.hasNewMessage ? Colors.blue[50] : Colors.transparent,
            ),
            child: Row(
              children: [
                Avatar(url: user.photoUrl, size: 50),
                spaceXsm,
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${user.name} ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            if (room.hasNewMessage) ...[
                              spaceSm,
                              Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blue[200],
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${room.newMessages}',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ]
                          ],
                        ),
                        spaceXxs,
                        Text(
                          room.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: bodyText4,
                        ),
                      ]),
                ),
                spaceXsm,
                IconButton(
                  onPressed: () async {
                    final re = await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Are you sure you want to delete?"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(
                                    'Yes',
                                    style: TextStyle(
                                        color: Colors.greenAccent[700]),
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(
                                    'No',
                                    style:
                                        TextStyle(color: Colors.redAccent[700]),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                    if (re == false) return;
                    room.deleteOtherUserRoom();
                  },
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
