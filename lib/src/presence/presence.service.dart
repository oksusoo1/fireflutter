import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../fireflutter.dart';

enum PresenceStatus { online, offline, away }

/// See readme.md
class PresenceService {
  static PresenceService? _instance;
  static PresenceService get instance {
    _instance ??= PresenceService();
    return _instance!;
  }

  late final ErrorCallback onError;

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
  activate({required ErrorCallback onError}) {
    this.onError = onError;
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

  /// set presence
  ///
  /// It waits until the presence status is compltely written on database with
  /// async/await
  setPresence(PresenceStatus status) async {
    /// If uid is not set (means, no user logged into the device), then just return.
    if (uid == null) return;

    final data = {
      'status': status.name,
      'timestamp': ServerValue.timestamp,
    };
    try {
      await presence.set(data);
    } catch (e) {
      onError(e);
    }
  }
}
