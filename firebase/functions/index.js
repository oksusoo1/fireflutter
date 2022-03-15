"use strict";

const functions = require("firebase-functions");
const admin = require("firebase-admin");
// const {now} = require("lodash");
// const {topic} = require("firebase-functions/v1/pubsub");

admin.initializeApp();

const lib = require("./lib");

/**
 * Run from functions shell
 * ```
 * sendMessageOnPostCreate({
 *  title: 'from functions shell',
 *  content: 'Content', category: 'qna',
 *  uid: 'o0BtHX2JMiaa0SIrDJ3qhDczXDF2'
 * }, {
 *   params: {postId: 'post_ccc'}
 * })
 * ```
 */
exports.sendMessageOnPostCreate = functions
    .region("asia-northeast3")
    .firestore.document("/posts/{postId}")
    .onCreate((snapshot, context) => {
      const category = snapshot.data().category;

      const payload = lib.topicPayload("posts_" + category, {
        title: snapshot.data().title ? snapshot.data().title : "",
        body: snapshot.data().content ? snapshot.data().content : "",
        postId: context.params.postId,
        type: "post",
        uid: snapshot.data().uid,
      });
      return admin.messaging().send(payload);
    });

// sendMessageOnCommentCreate({
// content: 'new items for sale',
// postId: '5xMgi3d3vYNabM0JbrSQ',
// parentId: 'A6tMQIhWWKQhbWkyoJf1',
// uid: '1h0pWRlRkEOgQedJL5HriYMxqTw2'},
// {params:{commentId:'eIpYHUmYGKUf921B9fRj'}})
exports.sendMessageOnCommentCreate = functions
    .region("asia-northeast3")
    .firestore.document("/comments/{commentId}")
    .onCreate(async (snapshot, context) => {
      const data = snapshot.data();
      // get root post
      const post = await lib.getPost(data.postId);

      const messageData = {
        title: "New Comment: " + post.data().title ? post.data().title : "",
        body: snapshot.data().content,
        postId: snapshot.data().postId,
        type: "post",
        uid: snapshot.data().uid,
      };
      const topic = "comments_" + post.data().category;
      // send push notification to topics
      await admin.messaging().send(lib.topicPayload(topic, messageData));

      // get comment ancestors
      const ancestorsUid = await lib.getCommentAncestors(
          context.params.commentId,
          snapshot.data().uid,
      );

      // add the post uid if the comment author is not the post author
      if (post.data().uid != snapshot.data().uid && !ancestorsUid.includes(post.data().uid)) {
        ancestorsUid.push(post.data().uid);
      }

      // Don't send the same message twice to topic subscribers and comment notifyees.
      //
      const userUids = await lib.getCommentNotifyeeWithoutTopicSubscriber(ancestorsUid, topic);

      // get users tokens
      const tokens = await lib.getTokensFromUids(userUids);

      return lib.sendingMessageToTokens(tokens, lib.preMessagePayload(messageData));
    });

/**
 * Indexes a user document whenever it is created (someone registered a new account).
 *
 * createUserIndex({
 *  uid: '...',
 *  ...
 * })
 */
exports.createUserIndex = functions.auth.user().onCreate((user) => {
  return lib.indexUserDocument(user.uid, user);
});

/**
 * Updates a user document index.
 *
 * updateUserIndex({
 *   before: {},
 *   after: { firstName: '...'  }
 *  }, {
 *   params: { userId: '...' }
 * })
 */
exports.updateUserIndex = functions
    .region("asia-northeast3")
    .database.ref("/users/{userId}")
    .onUpdate((change, context) => {
      const data = change.after.val();
      //  console.log('user data change after', context.params.userId, data);
      return lib.indexUserDocument(context.params.userId, data);
    });

/**
 * Deletes indexing whenever a user document is deleted (user resignation).
 *
 * deleteUserIndex({
 *  uid: '...'
 * })
 */
exports.deleteUserIndex = functions.auth.user().onDelete((user) => {
  return lib.deleteIndexedUserDocument(user.uid);
});

/**
 * Indexes a post document when it is created.
 *
 * createPostIndex({
 *  uid: 'user_ccc',
 *  category: 'discussion',
 *  title: 'I post on discussion',
 *  content: 'Discussion'
 * })
 */
exports.createPostIndex = functions
    .region("asia-northeast3")
    .firestore.document("/posts/{postId}")
    .onCreate((snap, context) => {
      return lib.indexPost(context.params.postId, snap.data());
    });

/**
 * Updates or delete the indexed document when a post is updated or deleted.
 *
 * Update:
 *  updatePostIndex({
 *   before: {},
 *   after: {
 *    uid: 'user_ccc',
 *    category: 'discussion',
 *    title: 'I post on discussion (update)',
 *    content: 'Discussion 2'
 *    }},
 *    { params: { postId: 'postId2' }
 *   })
 *
 *  Delete:
 *  updatePostIndex({
 *   before: {},
 *   after: { deleted: true }},
 *   { params: { postId: 'psot-id' }
 *  })
 */
exports.updatePostIndex = functions
    .region("asia-northeast3")
    .firestore.document("/posts/{postId}")
    .onUpdate((change, context) => {
      const data = change.after.data();
      if (data["deleted"]) {
        return lib.deleteIndexedPost(context.params.postId);
      } else {
        return lib.indexPost(context.params.postId, data);
      }
    });

// Indexes a comment document when it is created.
//
// createCommentIndex({ uid: 'user_ccc', content: 'Discussion' })
exports.createCommentIndex = functions
    .region("asia-northeast3")
    .firestore.document("/comments/{commentId}")
    .onCreate((snap, context) => {
      return lib.indexComment(context.params.commentId, snap.data());
    });

// Updates or delete the indexed document when a comment is updated or deleted.
//
// Update:
//  updateCommentIndex({
//   before: {},
//   after: { content: '...' }},
//   { params: { commentId: 'comment-id' }
//  })
//
// Delete:
//  updateCommentIndex({
//   before: {},
//   after: { deleted: true }},
//   { params: { commentId: 'comment-id' }
//  })
exports.updateCommentIndex = functions
    .region("asia-northeast3")
    .firestore.document("/comments/{commentId}")
    .onUpdate((change, context) => {
      const data = change.after.data();
      if (data["deleted"]) {
        return lib.deleteIndexedComment(context.params.commentId);
      } else {
        return lib.indexComment(context.params.commentId, data);
      }
    });

exports.sendMessageToAll = functions.region("asia-northeast3").https.onRequest(async (req, res) => {
  const query = req.query;
  query["topic"] = "defaultTopic";
  res.status(200).send(await lib.sendMessageToTopic(query));
});

exports.sendMessageToTopic = functions
    .region("asia-northeast3")
    .https.onRequest(async (req, res) => {
      res.status(200).send(await lib.sendMessageToTopic(req.query));
    });

exports.sendMessageToTokens = functions
    .region("asia-northeast3")
    .https.onRequest(async (req, res) => {
      res.status(200).send(await lib.sendMessageToTokens(req.query));
    });

exports.sendMessageToUsers = functions
    .region("asia-northeast3")
    .https.onRequest(async (req, res) => {
      res.status(200).send(await lib.sendMessageToUsers(req.query));
    });

exports.updateFileParentIdForPost = functions
    .region("asia-northeast3")
    .firestore.document("/posts/{postId}")
    .onWrite((change, context) => {
      return lib.updateFileParentId(context.params.postId, change.after.data());
    });

exports.updateFileParentIdForComment = functions
    .region("asia-northeast3")
    .firestore.document("/comments/{commentId}")
    .onWrite((change, context) => {
      return lib.updateFileParentId(context.params.commentId, change.after.data());
    });

exports.disableUser = functions.region("asia-northeast3").https.onCall(async (data, context) => {
  return await lib.disableUser(data, context);
});
exports.enableUser = functions.region("asia-northeast3").https.onCall(async (data, context) => {
  return await lib.enableUser(data, context);
});

exports.testAnswer = functions.region("asia-northeast3").https.onCall(async (data, context) => {
  return await lib.testAnswer(data, context);
});
