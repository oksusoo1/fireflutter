import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/src/chat/chat.data.model.dart';
import 'package:fireflutter/src/chat/chat.defines.dart';
import 'package:fireflutter/src/chat/chat.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:paginate_firestore/bloc/pagination_cubit.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class ChatRoom extends StatefulWidget {
  ChatRoom({
    required this.otherUid,
    required this.onError,
    required this.onUpdateOtherUserRoomInformation,
    required this.messageBuilder,
    required this.inputBuilder,
    this.emptyDisplay,
    Key? key,
  }) : super(key: key);

  final Function onError;

  /// [onUpdateOtherUserRoomInformation] is being invoked after room information
  /// had updated when user chat.
  final Function onUpdateOtherUserRoomInformation;
  final MessageBuilder messageBuilder;
  final InputBuilder inputBuilder;
  final Widget? emptyDisplay;

  /// Firebase user uid
  // final String myUid;
  final String otherUid;

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  ChatService service = ChatService.instance;
  bool fetching = false;
  final int fetchNum = 20;
  bool noMore = false;

  List<ChatMessageModel> messages = [];

  /// messages collection of chat user.
  late CollectionReference _messagesCol =
      FirebaseFirestore.instance.collection('chat/messages/$roomId');

  ///
  late CollectionReference _myRoomCol = service.roomsCol;
  // FirebaseFirestore.instance.collection('chat/rooms/${widget.myUid}');
  late CollectionReference _otherRoomCol =
      FirebaseFirestore.instance.collection('chat/rooms/${widget.otherUid}');

  // /chat/rooms/[my-uid]/[other-uid]
  DocumentReference get _myRoomDoc => _myRoomCol.doc(widget.otherUid);

  /// /chat/rooms/[other-uid]/[my-uid]
  DocumentReference get _otherRoomDoc => _otherRoomCol.doc(service.myUid);

  int page = 0;

  /// Get room id from login user and other user.
  String get roomId => service.getRoomId(widget.otherUid);

  @override
  void initState() {
    super.initState();
    service.otherUid = widget.otherUid;
    _myRoomDoc.set({'newMessages': 0}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: PaginateFirestore(
              // Use SliverAppBar in header to make it sticky
              // header: const SliverToBoxAdapter(child: Text('HEADER')),
              footer: const SliverToBoxAdapter(child: SizedBox(height: 16)),

              itemsPerPage: 20,

              reverse: true,
              //item builder type is compulsory.
              itemBuilder: (context, documentSnapshots, index) {
                final data = documentSnapshots[index].data() as Map?;
                final message =
                    ChatMessageModel.fromJson(data!, documentSnapshots[index].reference);
                return widget.messageBuilder(message);
              },
              // orderBy is compulsory to enable pagination
              query: _messagesCol.orderBy('timestamp', descending: true),
              //Change types accordingly
              itemBuilderType: PaginateBuilderType.listView,
              // To update db data in real time.
              isLive: true,

              // initialLoader: Row(
              //   children: [Icon(Icons.local_dining), Text('Initial loader ...')],
              // ),

              ///
              // bottomLoader: Row(
              //   children: [Icon(Icons.timer), Text('More ...!')],
              // ),

              /// This will be invoked whenever it displays a new message. (from the login user or the other user.)
              onLoaded: (PaginationLoaded loaded) {
                // print('page loaded; reached to end?; ${loaded.hasReachedEnd}');
                // print('######################################');
                _myRoomDoc.set({'newMessages': 0}, SetOptions(merge: true));
              },
              onReachedEnd: (PaginationLoaded loaded) {
                // This is called only one time when it reaches to the end.
                // print('Yes, Reached to end!!');
              },
              onPageChanged: (int no) {
                /// onPageChanged works on [PaginateBuilderType.pageView] only.
                // print('onPageChanged() => page no; $no');
              },
              onEmpty: widget.emptyDisplay != null
                  ? widget.emptyDisplay!
                  : Center(child: Text('No chats, yet. Please send some message.')),
              // separator: Divider(color: Colors.blue),
            ),
          ),
          SafeArea(child: widget.inputBuilder(onSubmitText)),
        ],
      ),
    );
  }

  void onSubmitText(String text) {
    final data = {
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'from': service.myUid,
      'to': widget.otherUid,
    };
    _messagesCol.add(data).then((value) {});

    /// When the login user send message, clear newMessage.
    data['newMessages'] = 0;
    _myRoomDoc.set(data);

    data['newMessages'] = FieldValue.increment(1);
    _otherRoomDoc.set(data, SetOptions(merge: true)).then((value) {
      widget.onUpdateOtherUserRoomInformation(data);
    });
  }
}
