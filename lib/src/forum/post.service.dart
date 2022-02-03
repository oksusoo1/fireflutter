// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fireflutter/fireflutter.dart';

// /// See readme.md
// class PostService with FirestoreBase {
//   static PostService? _instance;
//   static PostService get instance {
//     _instance ??= PostService();
//     return _instance!;
//   }

//   /// Increases the view counter.
//   ///
//   /// Firestore normally works fine by surpassing 1 write in 1 second per document.
//   Future<void> increaseViewCounter(String id) {
//     return postDoc(id).update({'viewCounter': FieldValue.increment(1)});
//   }
// }
