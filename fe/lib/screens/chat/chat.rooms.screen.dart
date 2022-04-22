import 'package:fe/screens/chat/chat.room.screen.dart';
import 'package:fe/screens/chat/chat.rooms.blocked.screen.dart';
import 'package:fe/screens/chat/widgets/chat.rooms.empty.dart';
import 'package:fe/service/app.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:extended/extended.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRoomsScreen extends StatelessWidget {
  const ChatRoomsScreen({Key? key}) : super(key: key);

  static const String routeName = '/chatRooms';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Rooms'),
      ),
      body: Auth(
        signedIn: (u) => Column(
          children: [
            Text('my uid: ' + FirebaseAuth.instance.currentUser!.uid),
            Row(children: [
              TextButton(
                  onPressed: () {
                    AppService.instance.open(ChatRoomsBlockedScreen.routeName);
                  },
                  child: const Text('Block list')),
            ]),
            Expanded(
              child: ChatRooms(
                itemBuilder: (ChatMessageModel room) => ChatRoomsUser(room),
                onEmpty: ChatRoomsEmpty(),
              ),
            ),
          ],
        ),
        signedOut: () => ChatRoomsEmpty(),
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
          onTap: () => AppService.instance.open(
            ChatRoomScreen.routeName,
            arguments: {'uid': widget.room.otherUid},
          ),
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
                              '${user.displayName} ',
                              style: const TextStyle(
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
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blue[200],
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${room.newMessages}',
                                style: const TextStyle(fontWeight: FontWeight.w500),
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
                    ],
                  ),
                ),
                spaceXsm,
                Popup(
                  icon: const Icon(Icons.menu),
                  options: {
                    'friendMap': PopupOption(
                      icon: const Icon(Icons.map),
                      label: 'Friend Map',
                    ),
                    'block': PopupOption(
                      icon: const Icon(Icons.block),
                      label: 'Block',
                    ),
                    'delete': PopupOption(
                      icon: const Icon(Icons.delete_forever_rounded),
                      label: 'Delete',
                    ),
                    'close': PopupOption(
                      icon: const Icon(Icons.cancel),
                      label: 'Close',
                    ),
                  },
                  initialValue: '',
                  onSelected: (v) async {
                    if (v == 'friendMap') {
                      final pos = await LocationService.instance.currentPosition;
                      ChatService.instance.send(
                        text: ChatMessageModel.createProtocol(
                            'friendMap', '${pos.latitude},${pos.longitude}'),
                        otherUid: widget.room.otherUid,
                        clearNewMessage: false,
                      );
                      InformService.instance.inform(widget.room.otherUid, {
                        'type': 'FriendMap',
                        'latitude': pos.latitude,
                        'longitude': pos.longitude,
                      });
                    } else if (v == 'delete') {
                      final re = await confirm('Delete', 'Do you want to delete?');
                      if (re == false) return;
                      room.deleteRoom();
                    } else if (v == 'block') {
                      ChatService.instance.blockUser(widget.room.otherUid);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
