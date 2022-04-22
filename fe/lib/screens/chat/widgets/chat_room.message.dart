import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_4.dart';

class ChatRoomMessage extends StatelessWidget {
  const ChatRoomMessage(this.message, {Key? key}) : super(key: key);

  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChatBubble(
          elevation: 0,
          backGroundColor: message.isMine
              ? Colors.yellow[600]!.withAlpha(234)
              : Colors.grey[200],
          alignment:
              message.isMine ? Alignment.centerRight : Alignment.centerLeft,
          margin: const EdgeInsets.all(4),
          clipper: ChatBubbleClipper4(
            type: message.isMine
                ? BubbleType.sendBubble
                : BubbleType.receiverBubble,
          ),
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width / 1.5),
            child: Column(
              crossAxisAlignment: message.isMine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (message.isImage)
                  Image.network(
                    message.text,
                    errorBuilder: (_, o, s) => Text(
                      message.text,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                if (!message.isImage)
                  Text(message.text, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                Text(message.time, style: const TextStyle(fontSize: 8)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
