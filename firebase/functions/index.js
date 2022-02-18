"use strict";

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { now } = require("lodash");
const { topic } = require("firebase-functions/v1/pubsub");

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
    .onCreate((snapshot) => {
        const category = snapshot.data().category;
        const payload = {
            notification: {
                title: snapshot.data().title ? snapshot.data().title : '',
                body: snapshot.data().content ? snapshot.data().content : '',
                clickAction: 'FLUTTER_NOTIFICATION_CLICK'
            },
            data:{
                id: context.params.postId,
                type: 'post',
                sender_uid: snapshot.data().uid
            }
        };
        const topic = "posts_" + category;
        console.info("topic; ", topic);
        return admin.messaging().sendToTopic(topic, payload);
    });

// sendMessageOnCommentCreate({content: 'new items for sale', postId: '5xMgi3d3vYNabM0JbrSQ', parentId: 'A6tMQIhWWKQhbWkyoJf1'
//, uid: '1h0pWRlRkEOgQedJL5HriYMxqTw2'},{params:{commentId:'eIpYHUmYGKUf921B9fRj'}})
exports.sendMessageOnCommentCreate = functions
  .region("asia-northeast3")
  .firestore
  .document("/comments/{commentId}")
  .onCreate(async (snapshot, context) => {
      // get root post
      const post = await admin.firestore().collection('posts').doc(snapshot.data().postId).get();

      // prepare notification
      const payload = {
          notification: {
              title: "New Comment: " + post.data().title ?? '',
              body: snapshot.data().content,
              clickAction: 'FLUTTER_NOTIFICATION_CLICK'
          },
          data:{
              id: snapshot.data().postId,
              type: 'post',
              sender_uid: snapshot.data().uid
          }
      };

      // comment topic
      const topic = "comments_" + post.data().category;

      // send push notification to topics
      const res = await admin.messaging().sendToTopic(topic, payload);

      // get comment ancestors 
      const ancestors_uid = await lib.getCommentAncestors(context.params.commentId, snapshot.data().uid);
      
      // add the post uid if the comment author is not the post author
      if(post.data().uid != snapshot.data().uid && !ancestors_uid.includes(post.data().uid)) {
        ancestors_uid.push(post.data().uid);
      }

      // remove subcriber uid but want to get notification under their post/comment
      const user_uids = await lib.removeTopicAndForumAncestorsSubscriber(ancestors_uid, topic);


      // get users tokens
      const tokens = await lib.getTokensFromUid(user_uids);

      if(tokens.length == 0) return [];

      // chuck token to 1000 https://firebase.google.com/docs/cloud-messaging/send-message#send-to-individual-devices
      // You can send messages to up to 1000 devices in a single request. 
      // If you provide an array with over 1000 registration tokens, 
      // the request will fail with a messaging/invalid-recipient error.
      const chunks = lib.chunk(tokens, 1000);

      const sendToDevicePromise = [];
      for(let c of chunks) {
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
                'Failure sending notification to',
                chunks[i][index],
                error
              );
              // Cleanup the tokens who are not registered anymore.
              if (error.code === 'messaging/invalid-registration-token' ||
                  error.code === 'messaging/registration-token-not-registered') {
                tokensToRemove.push(admin.firestore().collection('message-tokens').doc(chunks[i][index]).delete());
              }
            }
          });
        }
      );
      return Promise.all(tokensToRemove);
  });





// Index when a post is created
//
// meilisearchCreatePostIndex({ uid: 'user_ccc', category: 'discussion', title: 'I post on discussion', content: 'Discussion' })
exports.meilisearchCreatePostIndex = functions
    .region("asia-northeast3").firestore
    .document("/posts/{postId}")
    .onCreate((snap, context) => {
      return lib.indexPost(context.params.postId, snap.data());
    });

// Update the index when a post is updated or deleted.
// todo - create 'posts-and-comments' index.
//
// Test call:
//  meilisearchUpdatePostIndex({ before: {}, after: { uid: 'user_ccc', category: 'discussion', title: 'I post on discussion (update)', content: 'Discussion 2'}}, { params: { postId: 'postId2' }})
exports.meilisearchUpdatePostIndex = functions
    .region("asia-northeast3").firestore
    .document("/posts/{postId}")
    .onUpdate((change, context) => {
      return lib.indexPost(context.params.postId, change.after.data());
    });

exports.meilisearchCreateCommentIndex = functions
    .region("asia-northeast3").firestore
    .document("/comments/{commentId}")
    .onCreate((snap, context) => {
      return indexComment(context.params.commentId, snap.data());
    });

exports.meilisearchUpdateCommentIndex = functions
    .region("asia-northeast3").firestore
    .document("/comments/{commentId}")
    .onUpdate((change, context) => {
      return indexComment(context.params.commentId, change.after.data());
    });
