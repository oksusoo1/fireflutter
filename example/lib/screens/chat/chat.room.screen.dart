import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({Key? key}) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final chat = Chat(otherUid: Get.arguments['uid']);

  @override
  void initState() {
    super.initState();

    test();
  }

  test() async {
    try {
      await chat.send(message: 'hi there');
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat room'),
      ),

      /// TODO 4. list with `https://firebase.flutter.dev/docs/ui/database#installation`
      /// TODO 5. Display if user is online or offline.
      body: Container(),
    );
  }
}
