// import 'dart:convert';

// import 'package:fe/screens/chat/widgets/chat_room.message_box.dart';
// import 'package:fireflutter/fireflutter.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutterfire_ui/database.dart';

// class ChatRoomScreen extends StatefulWidget {
//   const ChatRoomScreen({Key? key}) : super(key: key);

//   @override
//   State<ChatRoomScreen> createState() => _ChatRoomScreenState();
// }

// class _ChatRoomScreenState extends State<ChatRoomScreen> {
//   final chat = Chat(otherUid: Get.arguments['uid']);
//   @override
//   void initState() {
//     super.initState();

//     test();
//   }

//   test() async {
//     // try {
//     //   await chat.send(message: 'hi there');
//     // } catch (e) {
//     //   print(e);
//     // }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chat room'),
//       ),
//       bottomNavigationBar: SafeArea(
//         child: ChatRoomMessageBox(onSend: chat.send),
//       ),
//       body: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: FirebaseDatabaseQueryBuilder(
//             query: chat.room.orderByKey(),
//             builder: (context, snapshot, _) {
//               if (snapshot.isFetching) {
//                 return const CircularProgressIndicator.adaptive();
//               }
//               if (snapshot.hasError) {
//                 return Text('Something went wrong! ${snapshot.error}');
//               }

//               return ListView.builder(
//                 itemCount: snapshot.docs.length,
//                 itemBuilder: (context, index) {
//                   // if we reached the end of the currently obtained items, we try to
//                   // obtain more items
//                   if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
//                     // Tell FirebaseDatabaseQueryBuilder to try to obtain more items.
//                     // It is safe to call this function from within the build method.
//                     snapshot.fetchMore();
//                   }

//                   final data = MessageModel.fromJson(snapshot.docs[index].value);

//                   return Container(
//                     padding: const EdgeInsets.all(8),
//                     color: Colors.teal[100],
//                     child: Text("- ${data.message}"),
//                   );
//                 },
//               );
//             },
//           )),
//     );
//   }
// }
