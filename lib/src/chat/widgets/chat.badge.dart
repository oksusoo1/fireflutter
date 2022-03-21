import '../../../fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart';

class ChatBadge extends StatefulWidget {
  const ChatBadge({Key? key}) : super(key: key);

  @override
  State<ChatBadge> createState() => _ChatBadgeState();
}

class _ChatBadgeState extends State<ChatBadge> {
  int no = 0;
  @override
  void initState() {
    super.initState();
    ChatService.instance.newMessages.listen((value) {
      if (mounted)
        setState(() {
          no = value;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (no == 0) return SizedBox.shrink();
    return Badge(
      toAnimate: false,
      shape: BadgeShape.circle,
      badgeColor: Colors.red,
      elevation: 0,
      padding: EdgeInsets.all(3.0),
      badgeContent: Text(
        no.toString(),
        style: TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}
