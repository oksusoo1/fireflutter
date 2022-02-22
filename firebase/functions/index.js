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
    .firestore
    .document("/posts/{postId}")
    .onCreate((snapshot, context) => {
      const category = snapshot.data().category;
      const payload = {
        notification: {
          title: snapshot.data().title ? snapshot.data().title : "",
          body: snapshot.data().content ? snapshot.data().content : "",
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
        data: {
          id: context.params.postId,
          type: "post",
          sender_uid: snapshot.data().uid,
        },
      };
      const topic = "posts_" + category;
      console.info("topic; ", topic);
      return admin.messaging().sendToTopic(topic, payload);
    });

// sendMessageOnCommentCreate({
// content: 'new items for sale',
// postId: '5xMgi3d3vYNabM0JbrSQ',
// parentId: 'A6tMQIhWWKQhbWkyoJf1',
// uid: '1h0pWRlRkEOgQedJL5HriYMxqTw2'},
// {params:{commentId:'eIpYHUmYGKUf921B9fRj'}})
exports.sendMessageOnCommentCreate = functions
    .region("asia-northeast3")
    .firestore
    .document("/comments/{commentId}")
    .onCreate(async (snapshot, context) => {
      // get root post
      const post = await admin
          .firestore()
          .collection("posts")
          .doc(snapshot.data().postId)
          .get();

      // prepare notification
      const payload = {
        notification: {
          title: "New Comment: " + post.data().title ? post.data().title : "",
          body: snapshot.data().content,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
        data: {
          id: snapshot.data().postId,
          type: "post",
          sender_uid: snapshot.data().uid,
        },
      };

      // comment topic
      const topic = "comments_" + post.data().category;

      // send push notification to topics
      await admin.messaging().sendToTopic(topic, payload);

      // get comment ancestors
      const ancestorsUid = await lib.getCommentAncestors(context.params.commentId, snapshot.data().uid);

      // add the post uid if the comment author is not the post author
      if (post.data().uid != snapshot.data().uid && !ancestorsUid.includes(post.data().uid)) {
        ancestorsUid.push(post.data().uid);
      }

      // remove subcriber uid but want to get notification under their post/comment
      const userUids = await lib.removeTopicAndForumAncestorsSubscriber(ancestorsUid, topic);


      // get users tokens
      const tokens = await lib.getTokensFromUid(userUids);

      if (tokens.length == 0) return [];

      // chuck token to 1000 https://firebase.google.com/docs/cloud-messaging/send-message#send-to-individual-devices
      // You can send messages to up to 1000 devices in a single request.
      // If you provide an array with over 1000 registration tokens,
      // the request will fail with a messaging/invalid-recipient error.
      const chunks = lib.chunk(tokens, 1000);

      const sendToDevicePromise = [];
      for (const c of chunks) {
        // Send notifications to all tokens.
        sendToDevicePromise.push(admin.messaging().sendToDevice(c, payload));
      }
      const sendDevice = await Promise.all(sendToDevicePromise);

      const tokensToRemove = [];
      sendDevice.forEach((response, i) => {
        // For each message check if there was an error.
        response.results.forEach((result, index) => {
          const error = result.error;
          if (error) {
            console.log(
                "Failure sending notification to",
                chunks[i][index],
                error,
            );
            // Cleanup the tokens who are not registered anymore.
            if (error.code === "messaging/invalid-registration-token" ||
                  error.code === "messaging/registration-token-not-registered") {
              tokensToRemove.push(admin.firestore().collection("message-tokens").doc(chunks[i][index]).delete());
            }
          }
        });
      },
      );
      return Promise.all(tokensToRemove);
    });


// todo - rename it to createPostIndex
// Indexes a post document when it is created.
//
// meilisearchCreatePostIndex({
//  uid: 'user_ccc',
//  category: 'discussion',
//  title: 'I post on discussion',
//  content: 'Discussion'
// })
exports.meilisearchCreatePostIndex = functions
    .region("asia-northeast3").firestore
    .document("/posts/{postId}")
    .onCreate((snap, context) => {
      return lib.indexPost(context.params.postId, snap.data());
    });

// todo - rename it to updatePostIndex
// Updates or delete the indexed document when a post is updated or deleted.
//
// Update:
// meilisearchUpdatePostIndex({
//  before: {},
//  after: {
//   uid: 'user_ccc',
//   category: 'discussion',
//   title: 'I post on discussion (update)',
//   content: 'Discussion 2'
//   }},
//   { params: { postId: 'postId2' }
//  })
//
// Delete:
// meilisearchUpdatePostIndex({
//  before: {},
//  after: { deleted: true }},
//  { params: { postId: 'psot-id' }
// })
exports.meilisearchUpdatePostIndex = functions
    .region("asia-northeast3").firestore
    .document("/posts/{postId}")
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
// meilisearchCreateCommentIndex({ uid: 'user_ccc', content: 'Discussion' })
exports.meilisearchCreateCommentIndex = functions
    .region("asia-northeast3").firestore
    .document("/comments/{commentId}")
    .onCreate((snap, context) => {
      return lib.indexComment(context.params.commentId, snap.data());
    });

// todo - rename it to updateCommentIndex
// Updates or delete the indexed document when a comment is updated or deleted.
//
// Update:
//  meilisearchUpdateCommentIndex({
//   before: {},
//   after: { content: '...' }},
//   { params: { commentId: 'comment-id' }
//  })
//
// Delete:
//  meilisearchUpdateCommentIndex({
//   before: {},
//   after: { deleted: true }},
//   { params: { commentId: 'comment-id' }
//  })
exports.meilisearchUpdateCommentIndex = functions
    .region("asia-northeast3").firestore
    .document("/comments/{commentId}")
    .onUpdate((change, context) => {
      const data = change.after.data();
      if (data["deleted"]) {
        return lib.deleteIndexedComment(context.params.commentId);
      } else {
        return lib.indexComment(context.params.commentId, data);
      }
    });


exports.sendPushNotification = functions.region("asia-northeast3").https.onRequest(async (req, res) => {
  // res.set("Access-Control-Allow-Origin", "*");
  // res.set("Access-Control-Allow-Methods", "GET");
  // res.set("Access-Control-Allow-Headers", "Content-Type");
  // res.set("Access-Control-Max-Age", "3600");
  // res.status(200).send((new Date).toDateString());
  console.log(req.query);

  const payload = {
    notification: {
      title: req.query.title,
      body: req.query.body,
    },
  };

  try {
    await admin.messaging().sendToTopic("/topics/" + req.query.topic, payload);
    res.status(200).send("success");
  } catch (e) {
    res.status(200).send("error" + e + JSON.stringify(payload) + JSON.stringify(req.body) + JSON.stringify(req.query));
  }
});
