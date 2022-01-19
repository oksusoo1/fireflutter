import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/src/chat/chat.data.model.dart';
import 'package:fireflutter/src/chat/chat.mixins.dart';
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
    print('countNewMessages()');
    if (roomSubscription != null) roomSubscription!.cancel();
    roomSubscription = roomsCol
        .where('newMessages', isGreaterThan: 0)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      int _newMessages = 0;
      snapshot.docs.forEach((doc) {
        ChatMessageModel room =
            ChatMessageModel.fromJson(doc.data() as Map, null);
        _newMessages += room.newMessages;
      });
      newMessages.add(_newMessages);
    });
  }

  clearNewMessages(String otherUid) {
    myOtherRoomInfoDoc(otherUid)
        .set({'newMessages': 0}, SetOptions(merge: true));
  }

  /// Send a chat message to other user even if the login user is not in chat room.
  ///
  /// Use case;
  ///   - send a message to B when A likes B's post.
  ///   - send a message to B when A request friend map to B.
  ///
  /// [cleaerNewMessage] should be true only when the login user is inside the room or entering the room.
  ///   - if the user is not inside the room, and simply send a message to a user without entering the room,
  ///     then this should be false, meaning, it does not reset the no of new message.
  Future<Map<String, dynamic>> send({
    required String text,
    required String otherUid,
    bool clearNewMessage: true,
  }) async {
    final data = {
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'from': myUid,
      'to': otherUid,
    };

    messagesCol(otherUid).add(data).then((value) {});

    /// When the login user is inside the chat room, it should clear no of new message.
    if (clearNewMessage) {
      data['newMessages'] = 0;
    }

    /// Update the room info under my chat room list,
    /// So once A sent a message to B for the first time, `B` is under A's room list.
    await myOtherRoomInfoDoc(otherUid).set(data, SetOptions(merge: true));

    /// count new messages and update it on the other user's room info.
    data['newMessages'] = FieldValue.increment(1);
    await otherMyRoomInfoDoc(otherUid).set(data, SetOptions(merge: true));
    return data;
  }

  /// block a user
  Future<void> blockUser(String otherUid) async {
    await myOtherRoomInfoDoc(otherUid).set({
      'text': ChatMessageModel.createProtocol('block'),
      'timestamp': FieldValue.serverTimestamp(),
      'from': myUid,
      'to': otherUid,
      'blocked': true,
    }, SetOptions(merge: true));

    /// Inform the other user.
    await send(
      text: ChatMessageModel.createProtocol('block'),
      otherUid: otherUid,
    );
  }
}
