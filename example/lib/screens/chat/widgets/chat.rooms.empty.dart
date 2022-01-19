import 'package:flutter/material.dart';
import 'package:extended/extended.dart';

class ChatRoomsEmpty extends StatelessWidget {
  ChatRoomsEmpty({Key? key}) : super(key: key);

  final textStyle = TextStyle(
      fontSize: 16, color: Colors.grey[400], fontWeight: FontWeight.w600);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height / 4),
          // Stack(alignment: Alignment.center, children: [
          //   FaIcon(FontAwesomeIcons.transporterEmpty, size: 200, color: Colors.grey[300]),
          //   FaIcon(FontAwesomeIcons.commentDots, size: 110, color: Colors.grey[400]),
          //   // Text('0', style: TextStyle(color: Colors.grey, fontSize: 60)),
          // ]),
          spaceSm,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: xxl, vertical: sm),
            child: Text(
              'No messages from friends, yet.\n You can send a message to friends by chat menu on forum.',
              style: textStyle,
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
