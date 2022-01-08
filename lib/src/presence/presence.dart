import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

enum PresenceStatus { online, offline, away }

/// See readme.md
class Presence {
  static Presence? _instance;
  static Presence get instance {
    _instance ??= Presence();
    return _instance!;
  }

  /// Currently logged in user.
  User? get user => FirebaseAuth.instance.currentUser;

  /// Set current user's uid or newly logged in user's uid for presence update.
  String? uid;

  /// Set offline by default
  PresenceStatus status = PresenceStatus.offline;

  late final StreamSubscription connectionSubscription;
  late final StreamSubscription presenceSubscription;

  DatabaseReference connected =
      FirebaseDatabase.instance.ref(".info/connected");
  DatabaseReference get presence =>
      FirebaseDatabase.instance.ref("presence").child(uid!);
  activate() {
    connectionSubscription = connected.onValue.listen((DatabaseEvent event) {
      setPresence(event.snapshot.value == true
          ? PresenceStatus.online
          : PresenceStatus.offline);
    });

    presenceSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        setPresence(PresenceStatus.offline);
        uid = null;
      } else {
        uid = user.uid;
        setPresence(PresenceStatus.online);

        /// Delete the 'presence' document when the app is closed.
        presence.onDisconnect().remove();
      }
    });
  }

  deactivate() {
    connectionSubscription.cancel();
    presenceSubscription.cancel();
  }

  setPresence(PresenceStatus status) async {
    /// If uid is not set (means, no user logged into the device), then just return.
    if (uid == null) return;

    final data = {
      'status': status.name,
      'timestamp': ServerValue.timestamp,
    };
    await presence.set(data);
  }
}
