// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fireflutter/fireflutter.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutterfire_ui/firestore.dart';

// class ReportForumManagement extends StatelessWidget with FirestoreMixin {
//   ReportForumManagement({ required target, required id, Key? key }) : super(key: key);

//   final String target;
//   final String id;


//   @override
//   Widget build(BuildContext context) {
//     Query? query;
//     CollectionReference q;
//     if(target == 'post') {
//        q = postCol;
//     } else if (target == 'comment') {
//       q = commentCol;
//     }
//     if (target != null) {
//       query = q.where('target', isEqualTo: target);
//     }

//     if (query != null) {
//       query = query.orderBy('timestamp');
//     } else {
//       query = q.orderBy('timestamp');
//     }

//     return FirestoreQueryBuilder(
//   query: moviesCollection.orderBy('title'),
//   builder: (context, snapshot, _) {
//     if (snapshot.isFetching) {
//       return const CircularProgressIndicator();
//     }
//     if (snapshot.hasError) {
//       return Text('error ${snapshot.error}');
//     }

//     return ListView.builder(
//       itemCount: snapshot.docs.length,
//       itemBuilder: (context, index) {
//         // if we reached the end of the currently obtained items, we try to
//         // obtain more items
//         if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
//           // Tell FirestoreQueryBuilder to try to obtain more items.
//           // It is safe to call this function from within the build method.
//           snapshot.fetchMore();
//         }

//         final movie = snapshot.docs[index];
//         return Text(movie.title);
//       },
//     );
//   },
// )
//   }
// }