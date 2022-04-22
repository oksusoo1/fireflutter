import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fireflutter.dart';
import 'package:rxdart/rxdart.dart';

class ChatService with ChatMixins {
  /// Singleton
  static ChatService? _instance;
  static ChatService get instance {
    if (_instance == null) {
      _instance = ChatService();
    }

    return _instance!;
  }

  // The other user's uid of current room.
  // Use to Identify which room the current user at.
  // Chat Push Notification check if otherUid is the sender then dont show the notification.
  String otherUid = '';

  /// Post [newMessages] event when there is a new message.
  ///
  /// Use this event to update the no of new chat messagges.
  /// * The app should unsubscribe [newMessages] if it is not used for life time.
  BehaviorSubject<int> newMessages = BehaviorSubject.seeded(0);

  // ignore: cancel_subscriptions
  StreamSubscription? roomSubscription;

  /// Counting new messages
  ///
  /// Call this method to count the number of new messages.
  ///
  /// Note, the subcriptions should be re-subscribe when user change accounts.
  /// Note, you may unsubscribe on your needs.
  ///
  ///
  countNewMessages() async {
    if (roomSubscription != null) roomSubscription!.cancel();
    roomSubscription = myRoomsCol
        .where('newMessages', isGreaterThan: 0)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      // print('countNewMessages() ... listen()');
      int _newMessages = 0;
      snapshot.docs.forEach((doc) {
        ChatMessageModel room =
            ChatMessageModel.fromJson(doc.data() as Map, null);
        _newMessages += room.newMessages;
      });
      newMessages.add(_newMessages);
    });
  }

  /// Unsubscribe for what `countNewMessages()` subscribed and
  /// update the number of new message to 0.
  ///
  /// The reason why it is posting 0 in [newMessage] event is to remove the badge.
  /// Or to remove the number of new chat message on profile if ever.
  /// Normally there will be a badge on user's profile and if the newMessage is 0,
  /// it should not display badge.
  unsubscribeNewMessages() {
    roomSubscription?.cancel();
    newMessages.add(0);
  }

  /// throws error if there is not permission.
  Future clearNewMessages(String otherUid) {
    return myOtherRoomInfoUpdate(otherUid, {'newMessages': 0});
  }

  /// Send a chat message
  /// It sends the chat message even if the login user is not in chat room.
  ///
  /// Important note that, this method updates 3 documents.
  ///   - /chat/rooms/<my>/<other>
  ///   - /chat/rooms/<other>/<my>
  ///   - /chat/messages/<uid>-<uid>
  ///   And if you update /chat/rooms/... in other place while sending a message,
  ///   then, document will be updated twice and listener handlers will be called twice
  ///   then, the screen may be flickering.
  ///   So, it has options to update myOtherData for `/chat/rooms/<my>/<other>`
  ///     and otherMyData for `/chat/rooms/<other>/<my>`.
  ///     with this, you can update the room info docs and you don't have to
  ///     update `/chat/rooms/...` separately.
  ///
  ///
  /// Use case;
  ///   - send a message to B when A likes B's post.
  ///   - send a message to B when A request friend map to B.
  ///
  /// [cleaerNewMessage] should be true only when the login user is inside the room or entering the room.
  ///   - if the user is not inside the room, and simply send a message to a user without entering the room,
  ///     then this should be false, meaning, it does not reset the no of new message.
  ///   - so, this option is only for logged in user.
  Future<Map<String, dynamic>> send({
    required String text,
    required String otherUid,
    bool clearNewMessage: true,
    Map<String, dynamic> myOtherData = const {},
    Map<String, dynamic> otherMyData = const {},
  }) async {
    final data = {
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'from': myUid,
      'to': otherUid,
    };

    /// Add a chat message under the chat room.
    try {
      await messagesCol(otherUid).add(data);
    } catch (e) {
      throw ERROR_CHAT_MESSAGE_ADD;
    }

    /// When the login user is inside the chat room, it should clear no of new message.
    if (clearNewMessage) {
      data['newMessages'] = 0;
    }

    /// Update the room info under my chat room list,
    /// So once A sent a message to B for the first time, `B` is under A's room list.
    await myOtherRoomInfoUpdate(otherUid, {...data, ...myOtherData});

    /// count new messages and update it on the other user's room info.
    data['newMessages'] = FieldValue.increment(1);
    await otherMyRoomInfoUpdate(otherUid, {...data, ...otherMyData});
    return data;
  }

  /// Room info document must be updated. Refer readme.
  ///
  /// Update my friend under
  ///   - /chat/rooms/<my-uid>/<other-uid>
  /// To make sure, all room info doc update must use this method.
  Future<void> myOtherRoomInfoUpdate(
      String otherUid, Map<String, dynamic> data) {
    return myRoomsCol.doc(otherUid).set(data, SetOptions(merge: true));
  }

  /// Room info document must be updated. Refer readme.
  ///
  /// Update my info under my friend's room list
  ///   - /chat/rooms/<other-uid>/<my-uid>
  /// To make sure, all room info doc update must use this method.
  Future<void> otherMyRoomInfoUpdate(
      String otherUid, Map<String, dynamic> data) {
    return otherRoomsCol(otherUid)
        .doc(myUid)
        .set(data, SetOptions(merge: true));
  }

  /// Return a room info doc under currently logged in user's room list.
  Future<DocumentSnapshot<Object?>> getRoomInfo(String otherUid) {
    return myRoomsCol.doc(otherUid).get();
  }

  /// Delete /chat/room/<my-uid>/<other-uid>
  Future<void> myOtherRoomInfoDelete(String otherUid) {
    return myRoomsCol.doc(otherUid).delete();
  }

  /// block a user
  Future<void> blockUser(String otherUid) {
    final futures = [
      myOtherRoomInfoDelete(otherUid),
      FirebaseFirestore.instance
          .collection('chat')
          .doc('blocks')
          .collection(myUid)
          .doc(otherUid)
          .set({
        'timestamp': FieldValue.serverTimestamp(),
      }),
    ];
    return Future.wait(futures);
  }

  /// unblock a user
  Future<void> unblockUser(String otherUid) {
    // print('unblock user');
    final futures = [
      FirebaseFirestore.instance
          .collection('chat')
          .doc('rooms')
          .collection(myUid)
          .doc(otherUid)
          .set({
        'from': myUid,
        'to': otherUid,
        'newMessage': 0,
        'text': '',
        'timestamp': FieldValue.serverTimestamp(),
      }),
      FirebaseFirestore.instance
          .collection('chat')
          .doc('blocks')
          .collection(myUid)
          .doc(otherUid)
          .delete(),
    ];
    return Future.wait(futures);
  }

  /// Get number of new messages for a user
  ///
  /// ! Warning - This will read many documents. Chat feature is based on firestore at this time and it's expensive.
  /// ! Warning - Change it to realtime database when time comes.
  Future<int> getNoOfNewMessages(String otherUid) async {
    /// Send push notification to the other user.
    QuerySnapshot querySnapshot = await ChatService.instance
        .otherRoomsCol(otherUid)
        .where('newMessages', isGreaterThan: 0)
        .get();

    int newMessages = 0;
    querySnapshot.docs.forEach((doc) {
      ChatMessageModel room = ChatMessageModel.fromJson(doc.data() as Map);
      newMessages += room.newMessages;
    });
    return newMessages;
  }
}
