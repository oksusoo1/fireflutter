import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import '../../fireflutter.dart';

class PostService with FirestoreMixin {
  static PostService? _instance;
  static PostService get instance {
    _instance ??= PostService();
    return _instance!;
  }

  Map<String, List<PostModel>> cacheContainer = {};

  /// Gets document from post collection
  ///
  /// if [cacheId] has value, then it will cache the documents in the memory.
  /// It will not get the same document again on app session.
  /// The default is null that means it will not cache by default.
  /// Caching posts in memory may save money.
  ///
  /// If [hasPhoto] is set to true, then it will get posts that has photo.
  /// If [hasPhoto] is set to false, then it will get posts that has not photo.
  /// If [hasPhoto] is set to null, then it will get posts wether it has photo or not.
  ///
  /// If [uid] is set, then it will search for the posts with that uid only.
  ///
  /// If [within] is set, then it will search for the posts within the [within] days only.
  Future<List<PostModel>> get({
    String? category,
    String? uid,
    int limit = 10,
    bool? hasPhoto,
    int? within,
    String? cacheId,
  }) async {
    if (cacheId != null && cacheContainer[cacheId] != null) {
      debugPrint('-----> Reusing cached posts for; $cacheId');
      return cacheContainer[cacheId]!;
    }
    Query q = postCol;
    if (category != null) q = q.where('category', isEqualTo: category);
    if (uid != null) q = q.where('uid', isEqualTo: uid);
    if (hasPhoto != null) q = q.where('hasPhoto', isEqualTo: hasPhoto);

    /// TODO: check if it's working.
    if (within != null) {
      q = q.where('timestamp',
          isGreaterThanOrEqualTo:
              Jiffy().subtract(days: within).format("yyyy-MM-dd"));
    }
    q = q.limit(limit);

    q = q.orderBy('timestamp', descending: true);

    QuerySnapshot snapshot = await q.get();

    List<PostModel> posts = [];
    snapshot.docs.forEach((doc) {
      posts.add(PostModel.fromJson(
        doc.data() as Map<String, dynamic>,
        doc.id,
      ));
    });
    if (cacheId != null) {
      cacheContainer[cacheId] = posts;
    }
    return posts;
  }

  Future<PostModel?> load(id) async {
    DocumentSnapshot doc = await postCol.doc(id).get();
    if (doc.exists == false) return null;
    return PostModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
  }
}
