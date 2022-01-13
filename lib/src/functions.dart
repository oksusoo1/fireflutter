// /// Chat room ID
// ///
// /// - Return chat room id of login user and the other user.
// /// - Chat room ID is composited with login user UID and other user UID by alphabetic order.
// ///   For instance,
// ///   - If myUid = 3 and otherUid = 4, then the result is "3-4".
// ///   - If myUid = 321 and otherUid = 1234, then the result is "1234-321"
// String getChatRoomId(String myUid, String otherUid) {
//   return myUid.compareTo(otherUid) < 0
//       ? "${myUid}__$otherUid"
//       : "${otherUid}__$myUid";
// }
