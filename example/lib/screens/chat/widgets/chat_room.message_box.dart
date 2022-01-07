import 'package:flutter/material.dart';

class ChatRoomMessageBox extends StatefulWidget {
  const ChatRoomMessageBox({
    required this.onSend,
    Key? key,
  }) : super(key: key);

  final void Function(String) onSend;
  @override
  State<ChatRoomMessageBox> createState() => _ChatRoomMessageBoxState();
}

class _ChatRoomMessageBoxState extends State<ChatRoomMessageBox> {
  final messageBoxController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    messageBoxController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: messageBoxController,
        onChanged: (t) => setState(() {}),
        onSubmitted: _send,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: const Icon(Icons.add_box_rounded),
          suffixIcon: messageBoxController.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: _send,
                  icon: const Icon(Icons.send),
                ),
        ),
      ),
    );
  }

  _send([String? x]) {
    widget.onSend(messageBoxController.text);
    messageBoxController.clear();
    setState(() {});
  }
}
