import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:paginate_firestore/bloc/pagination_cubit.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import '../../../fireflutter.dart';

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

  int page = 0;

  late ChatMessageModel roomInfo;

  @override
  void initState() {
    super.initState();
    service.otherUid = widget.otherUid;
    service.clearNewMessages(widget.otherUid).catchError(widget.onError);
    getRoomInfo();
  }

  getRoomInfo() async {
    DocumentSnapshot res =
        await ChatService.instance.getRoomInfo(widget.otherUid);
    // print(res);

    roomInfo = ChatMessageModel.fromJson(res.data() as Map);
  }

  @override
  void dispose() {
    super.dispose();
    service.otherUid = '';
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
                final message = ChatMessageModel.fromJson(
                    data!, documentSnapshots[index].reference);
                return widget.messageBuilder(message);
              },
              // orderBy is compulsory to enable pagination
              query: service
                  .messagesCol(widget.otherUid)
                  .orderBy('timestamp', descending: true),
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
                // _myRoomDoc.set({'newMessages': 0}, SetOptions(merge: true));
                service.clearNewMessages(widget.otherUid);
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
                  : Center(
                      child: Text('No chats, yet. Please send some message.')),
              // separator: Divider(color: Colors.blue),
            ),
          ),
          SafeArea(child: widget.inputBuilder(onSubmitText)),
        ],
      ),
    );
  }

  void onSubmitText(String text) async {
    try {
      final data = await service.send(text: text, otherUid: widget.otherUid);

      /// callback after sending a message to other user and updating the no of
      /// new messages on other user's room list.
      widget.onUpdateOtherUserRoomInformation(data);
    } catch (e) {
      widget.onError(e);
    }
  }
}
