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
  String otherUid = '';

  CollectionReference get otherRoomCol =>
      FirebaseFirestore.instance.collection('chat/rooms/$otherUid');

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
}
