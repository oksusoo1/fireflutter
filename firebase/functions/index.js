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
 * sendMessageOnPostCreateIndex({
 *  title: 'from functions shell',
 *  content: 'Content', category: 'qna',
 *  uid: 'o0BtHX2JMiaa0SIrDJ3qhDczXDF2'
 * }, {
 *   params: {postId: 'post_ccc'}
 * })
 * ```
 */
exports.sendMessageOnPostCreateIndex = functions
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
    .onCreate((snapshot, context) => {
      return lib.sendMessageOnCommentCreate(context.params.commentId, snapshot.data());
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
 * onPostCreateIndex({
 *  uid: 'user_ccc',
 *  category: 'discussion',
 *  title: 'I post on discussion',
 *  content: 'Discussion'
 * })
 *
 * @test how to run in shell
 * % npm run shell
 * > onPostCreateIndex({uid: 'a'}, {params: {postId: 'p-1'}});
 */
exports.onPostCreateIndex = functions
    .region("asia-northeast3")
    .firestore.document("/posts/{postId}")
    .onCreate((snapshot, context) => {
      return lib.indexPost(context.params.postId, snapshot.data());
    });

/**
 * Updates or delete the indexed document when a post is updated or deleted.
 *
 * Update:
 *  onPostUpdateIndex({
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
 *  onPostUpdateIndex({
 *   before: {},
 *   after: { deleted: true }},
 *   { params: { postId: 'psot-id' }
 *  })
 */
exports.onPostUpdateIndex = functions
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
// onCommentCreate({ uid: 'user_ccc', content: 'Discussion' })
/**
 *
 * @test how to run in shell
 * % npm run shell
 * > onCommentCreate({uid: 'a'}, {params: {commentId: 'c-1'}});
 */
exports.onCommentCreateIndex = functions
    .region("asia-northeast3")
    .firestore.document("/comments/{commentId}")
    .onCreate((snapshot, context) => {
      return lib.indexComment(context.params.commentId, snapshot.data());
    });

// Updates or delete the indexed document when a comment is updated or deleted.
//
// Update:
//  onCommentUpdateIndex({
//   before: {},
//   after: { content: '...' }},
//   { params: { commentId: 'comment-id' }
//  })
//
// Delete:
//  onCommentUpdateIndex({
//   before: {},
//   after: { deleted: true }},
//   { params: { commentId: 'comment-id' }
//  })
exports.onCommentUpdateIndex = functions
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

// / When a post or a comment had created with 'files', put the doc id on file meta.
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
  // / TODO: no need to await
  return await lib.disableUser(data, context);
});
exports.enableUser = functions.region("asia-northeast3").https.onCall(async (data, context) => {
  // / TODO: no need to await
  return await lib.enableUser(data, context);
});

exports.testAnswer = functions.region("asia-northeast3").https.onCall(async (data, context) => {
  // / TODO: no need to await
  return await lib.testAnswer(data, context);
});

// context.app will be undefined
// if the request doesn't include a valid App Check token.
// exports.testAppCheck = functions.region("asia-northeast3").https.onCall((data, context) => {
//   if (context.app == undefined) {
//     throw new functions.https.HttpsError(
//       "failed-precondition",
//       "The function must be called from an App Check verified app.",
//       context
//     );
//   }

//   return {
//     data: data,
//     context: context,
//   };
// });

/**
 * **************************** POINT FUNCTIONS ****************************
 */
/**
 * Listens for a new user to be register(created) at /users/:uid and do point event.
 * A doc will be created at /point/{uid}/register
 *
 * @test How to test
 * % npm run shell
 * % pointEventRegister({}, {params: {uid: 'a'}})
 */
exports.pointEventRegister = functions
    .region("asia-northeast3")
    .database.ref("/users/{uid}")
    .onCreate((snapshot, context) => {
      return lib.userRegisterPoint(snapshot.val(), context);
    });

/**
 * Listens for a user sign in and do point event.
 * A doc will be created at /point/{uid}/signIn/{pushId}
 *
 * @test How to test
 * % npm run shell
 * % pointEventSignIn({after: {lastLogin: 1234}}, {params: {uid: 'a'}})
 */
exports.pointEventSignIn = functions
    .region("asia-northeast3")
    .database.ref("/users/{uid}/lastSignInAt")
    .onUpdate((change, context) => {
      return lib.userSignInPoint(change.after.val(), context);
    });

/**
 * Listens for a user sign in and do point event.
 * A doc will be created at /point/{uid}/signIn/{pushId}
 *
 * @test How to test
 * % npm run shell
 * % onPostCreatePoint( {uid: 'a'}, {params: {postId: 'post-1'}} )
 */
exports.onPostCreatePoint = functions
    .region("asia-northeast3")
    .firestore.document("/posts/{postId}")
    .onCreate((snapshot, context) => {
      return lib.postCreatePoint(snapshot.data(), context);
    });

exports.onCommentCreatePoint = functions
    .region("asia-northeast3")
    .firestore.document("/comments/{commentId}")
    .onCreate((snapshot, context) => {
      return lib.commentCreatePoint(snapshot.data(), context);
    });

// **************************** EO POINT FUNCTIONS ****************************
