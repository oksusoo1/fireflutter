import 'package:fe/screens/chat/chat.room.screen.dart';
import 'package:fe/screens/chat/widgets/chat.rooms.empty.dart';
import 'package:fe/services/app.service.dart';
import 'package:fe/services/defines.dart';
import 'package:fe/services/global.dart';
import 'package:fe/widgets/layout/layout.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:extended/extended.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRoomsBlockedScreen extends StatelessWidget {
  const ChatRoomsBlockedScreen({Key? key}) : super(key: key);

  static const String routeName = '/chatRoomsBlockeed';

  @override
  Widget build(BuildContext context) {
    return Layout(
      backButton: true,
      title: const Text(
        'Chat Blocked Rooms',
        style: titleStyle,
      ),
      body: Auth(
        signedIn: (u) => Column(
          children: [
            Text('my uid: ' + FirebaseAuth.instance.currentUser!.uid),
            Row(children: [
              TextButton(
                onPressed: service.router.openChatRooms,
                child: const Text('Room list'),
              ),
            ]),
            Expanded(
              child: ChatRoomsBlocked(
                itemBuilder: (String otherUid) => ChatRoomsBlockUser(otherUid),
              ),
            ),
          ],
        ),
        signedOut: () => ChatRoomsEmpty(),
      ),
    );
  }
}

class ChatRoomsBlockUser extends StatefulWidget {
  const ChatRoomsBlockUser(this.otherUid, {Key? key}) : super(key: key);

  final String otherUid;
  @override
  State<ChatRoomsBlockUser> createState() => _ChatRoomsBlockUserState();
}

class _ChatRoomsBlockUserState extends State<ChatRoomsBlockUser> {
  String get otherUid => widget.otherUid;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return UserDoc(
      uid: otherUid,
      builder: (UserModel user) {
        return GestureDetector(
          onTap: () => AppService.instance.router.open(
            ChatRoomScreen.routeName,
            arguments: {'uid': otherUid},
          ),
          child: Container(
            margin: const EdgeInsets.all(xs),
            padding: const EdgeInsets.all(xs),
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
                        ],
                      ),
                      spaceXxs,
                    ],
                  ),
                ),
                spaceXsm,
                Popup(
                  icon: const Icon(Icons.menu),
                  options: {
                    'unblock': PopupOption(
                      icon: const Icon(Icons.block),
                      label: 'Unblock',
                    ),
                    'close': PopupOption(
                      icon: const Icon(Icons.cancel),
                      label: 'Close',
                    ),
                  },
                  initialValue: '',
                  onSelected: (v) async {
                    if (v == 'unblock') {
                      ChatService.instance.unblockUser(otherUid);
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
