import 'package:cloud_firestore/cloud_firestore.dart';

mixin ForumBase {
  Future<void> increaseForumViewCounter(DocumentReference doc) {
    return doc.update({'viewCounter': FieldValue.increment(1)});
  }
}
