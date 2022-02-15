"use strict";

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const Axios = require("axios");


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


exports.meilisearchIndexPost = functions
    .region("asia-northeast3").firestore
    .document("/posts/{postId}")
    .onCreate((snap, context) => {
      const data = {
        id: context.params.postId,
        title: snap.data().title,
        content: snap.data().content,
      };
      return Axios.post(
          "http://wonderfulkorea.kr:7700/indexes/posts/documents",
          data
      );
    });
