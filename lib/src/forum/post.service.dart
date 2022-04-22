import 'dart:async';

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

  /// Post container
  /// All loaded posts are contained here.
  /// `PostModel.fromJson` will put all the loaded post into [posts].
  Map<String, PostModel> posts = {};

  /// Comment container for each post.
  ///
  /// All the comments of each post are maintained in [comments].
  /// Comments should be saved in this variable when a post displays comments.
  Map<String, List<CommentModel>> comments = {};
  Map<String, Map<String, StreamSubscription>> commentSubscriptions = {};

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
      // debugPrint('-----> Reusing cached posts for; $cacheId');
      return cacheContainer[cacheId]!;
    }
    Query q = postCol;
    if (category != null) q = q.where('category', isEqualTo: category);
    if (uid != null) q = q.where('uid', isEqualTo: uid);
    if (hasPhoto != null) q = q.where('hasPhoto', isEqualTo: hasPhoto);

    /// Get posts within the date
    if (within != null) {
      q = q.where(
        'createdAt',
        isGreaterThanOrEqualTo:
            Jiffy().subtract(days: within).format("yyyy-MM-dd"),
      );
    }
    q = q.limit(limit);

    q = q.orderBy('createdAt', descending: true);

    QuerySnapshot snapshot;
    try {
      snapshot = await q.get();
    } on FirebaseException catch (e) {
      debugPrint("${e.code}, ${e.message ?? ''}");
      rethrow;
    }

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

  /// 게시판 바뀔 때, category 별 리스너 해제 및 comments[postId] 삭제
  ///
  loadComments(String category, String postId) {
    if (commentSubscriptions[category] == null)
      commentSubscriptions[category] = {};
    // already subscribed?
    if (commentSubscriptions[category]![postId] != null) return;

    /// It is listening any changes of the docs.
    commentSubscriptions[category]![postId] = commentCol
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt')
        .snapshots()
        .listen((QuerySnapshot snapshots) {
      snapshots.docs.forEach((QueryDocumentSnapshot snapshot) {
        if (comments[postId] == null) comments[postId] = [];

        /// is it immediate child?
        final CommentModel c =
            CommentModel.fromJson(snapshot.data() as Json, id: snapshot.id);
        // print(c);

        // if exists in array, just update it.
        int i = comments[postId]!.indexWhere((e) => e.id == snapshot.id);
        if (i >= 0) {
          /// maintain the depth computation
          c.depth = comments[postId]![i].depth;
          comments[postId]![i] = c;
        } else {
          /// if immediate child comment,
          if (c.postId == c.parentId) {
            /// add at bottom
            comments[postId]!.add(c);
          } else {
            /// It's a comment under another comemnt. Find parent.
            int i = comments[postId]!.indexWhere((e) => e.id == c.parentId);
            if (i >= 0) {
              c.depth = comments[postId]![i].depth + 1;
              comments[postId]!.insert(i + 1, c);
            } else {
              // error; can't find parent comment.
              // print('---> error?; $c');
            }
          }
        }
      });
      // PostService.instance.comments[widget.post.id] = comments;

      // setstate() here
    });
  }
}
