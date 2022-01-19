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
        ChatMessageModel room = ChatMessageModel.fromJson(doc.data() as Map, null);
        _newMessages += room.newMessages;
      });
      newMessages.add(_newMessages);
    });
  }

  clearNewMessages(String otherUid) {
    myOtherRoomInfoDoc(otherUid).set({'newMessages': 0}, SetOptions(merge: true));
  }

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

    /// When the login user send message, clear newMessage.
    if (clearNewMessage) {
      clearNewMessages(otherUid);
    }

    /// count new messages and update it on the other user's room info.
    data['newMessages'] = FieldValue.increment(1);
    await otherMyRoomInfoDoc(otherUid).set(data, SetOptions(merge: true));
    return data;
  }

  /// removes a user
  Future<void> blockUser(String otherUid) async {
    await otherMyRoomInfoDoc(otherUid).set({
      'text': 'ChatProtocol.block',
      'timestamp': FieldValue.serverTimestamp(),
      'from': myUid,
      'to': otherUid,
    }, SetOptions(merge: true));

    /// Inform all users.
    await send(
      text: 'ChatProtocol.block',
      otherUid: otherUid,
    );
  }
}
