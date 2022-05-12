import 'package:firebase_database/firebase_database.dart';
import '../../fireflutter.dart';
import 'package:flutter/material.dart';

enum PresenceType {
  online,
  offline,
  away,
}

class UserPresence extends StatefulWidget {
  const UserPresence({
    required this.uid,
    required this.builder,
    Key? key,
  }) : super(key: key);

  final String uid;
  final Widget Function(PresenceType) builder;

  @override
  State<UserPresence> createState() => _UserPresenceState();
}

class _UserPresenceState extends State<UserPresence> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        PresenceService.instance.setPresence(PresenceStatus.online);
        break;
      case AppLifecycleState.inactive:
        PresenceService.instance.setPresence(PresenceStatus.away);
        break;
      case AppLifecycleState.paused:
        PresenceService.instance.setPresence(PresenceStatus.away);
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref('presence').child(widget.uid).onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> event) {
        if (event.hasData && event.data!.snapshot.exists) {
          final String status = (event.data!.snapshot.value! as Map)['status'];

          if (status == PresenceStatus.online.name) {
            return widget.builder(PresenceType.online);
          } else if (status == PresenceStatus.away.name) {
            return widget.builder(PresenceType.away);
          } else {
            return widget.builder(PresenceType.offline);
          }
        } else {
          return widget.builder(PresenceType.offline);
        }
      },
    );
  }
}
