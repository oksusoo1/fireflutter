"use strict";

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const Axios = require("axios");
const { now } = require("lodash");
const { topic } = require("firebase-functions/v1/pubsub");


admin.initializeApp();


/**
 * Run from functions shell
 * ```
 * sendMessageOnPostCreate({
 *  title: 'from functions shell',
 *  content: 'Content', category: 'qna'
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
                title: "title: " + snapshot.data().title,
                body: snapshot.data().content,
            },
        };
        const topic = "posts_" + category;
        console.info("topic; ", topic);
        return admin.messaging().sendToTopic(topic, payload);
    });

// sendMessageOnCommentCreate({postId: 'zvVFkgE4p7cWgXd07yvf'})
exports.sendMessageOnCommentCreate = functions
  .region("asia-northeast3")
  .firestore
  .document("/comments/{commentId}")
  .onCreate(async (snapshot) => {
      console.log('snapshot.data().postId', snapshot.data().postId);
    
      const post = await admin.firestore().collection('posts').doc(snapshot.data().postId).get();
      console.info(post.data());
      
      const payload = {
          notification: {
              title: "New Comment: " + post.data().title,
              body: post.data().title,
          },
      };
      const topic = "comment_" + post.data().category;
      console.info("topic; ", topic);
      const res = await admin.messaging().sendToTopic(topic, payload);
       console.log(res);
       return res
  });




// message-token onCreate it will subscribe to `defaultTopic`.    
// exports.subscribeToMainTopicOnTokenCreate = functions
//     .region("asia-northeast3")
//     .firestore
//     .document("/message-tokens/{token}")
//     .onCreate((snapshot) => {
//         return admin.messaging().subscribeToTopic('defaultTopic', snapshot.data().id);
//     });


function indexPost(id, data) {


    console.log('--> data; ', data);

    const _data = {
        id: id,
        title: data.title,
        content: data.content,
    };

    return Axios.post(
        "http://wonderfulkorea.kr:7700/indexes/posts/documents",
        _data
    );
}

// Index when a post is created
exports.meilisearchCreatePostIndex = functions
    .region("asia-northeast3").firestore
    .document("/posts/{postId}")
    .onCreate((snap, context) => {
        return indexPost(context.params.postId, snap.data());
    });

// Update the index when a post is updated or deleted.
exports.meilisearchUpdatePostIndex = functions
    .region("asia-northeast3").firestore
    .document("/posts/{postId}")
    .onUpdate((change, context) => {
        const oldValue = change.before.data();
        console.log('--> oldValue; ', oldValue);
        const newValue = change.after.data();
        console.log('--> newValue; ', newValue);
        return indexPost(context.params.postId, newValue);
    });
