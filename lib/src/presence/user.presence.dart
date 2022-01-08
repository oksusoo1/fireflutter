import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class UserPresence extends StatefulWidget {
  const UserPresence(
      {required this.uid,
      required this.onlineBuilder,
      required this.offlineBuilder,
      required this.awayBuilder,
      Key? key})
      : super(key: key);

  final String uid;
  final Widget Function() onlineBuilder;
  final Widget Function() offlineBuilder;
  final Widget Function() awayBuilder;

  @override
  State<UserPresence> createState() => _UserPresenceState();
}

class _UserPresenceState extends State<UserPresence>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        Presence.instance.setPresence(PresenceStatus.online);
        break;
      case AppLifecycleState.inactive:
        Presence.instance.setPresence(PresenceStatus.away);
        break;
      case AppLifecycleState.paused:
        Presence.instance.setPresence(PresenceStatus.away);
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          FirebaseDatabase.instance.ref('presence').child(widget.uid).onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> event) {
        print(event.hasData);
        if (event.hasData && event.data!.snapshot.exists) {
          final String status = (event.data!.snapshot.value! as Map)['status'];
          if (status == PresenceStatus.online.name) {
            return widget.onlineBuilder();
          } else if (status == PresenceStatus.away.name) {
            return widget.awayBuilder();
          } else {
            return widget.offlineBuilder();
          }
        } else {
          return widget.offlineBuilder();
        }
      },
    );
  }
}
