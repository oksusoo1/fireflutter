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
              title: "New Comment: " + post.data().title,
              body: post.data().content,
          },
      };
      // comment topic
      const topic = "comments_" + post.data().category;
      // send push notification to topics
      // const res = await admin.messaging().sendToTopic(topic, payload);
      const ancestors_uid = await getCommentAncestors(context.params.commentId, snapshot.data().uid);

      const subscriber_uid = await removeCommentSubscriber(ancestors_uid, topic);

      const tokens = await getTokensFromUid(subscriber_uid);

      if(tokens.length == 0) return [];

      // Send notifications to all tokens.
      const response = await admin.messaging().sendToDevice(tokens, payload);
      // For each message check if there was an error.
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          functions.logger.error(
            'Failure sending notification to',
            tokens[index],
            error
          );
          // Cleanup the tokens who are not registered anymore.
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            tokensToRemove.push(admin.firestore().collection('message-tokens').child(tokens[index]).remove());
          }
        }
      });
      return Promise.all(tokensToRemove);
  });

  async function getCommentAncestors(id, authorUid) {
    let comment = await admin.firestore().collection('comments').doc(id).get();
    const uids = [];
    while(true) {
      if (comment.data().postId == comment.data().parentId ) break;
      comment = await admin.firestore().collection('comments').doc(comment.data().parentId).get();
      if(comment.exists == false) continue;
      if(comment.data().uid == authorUid) continue; //get author uid.
      uids.push(comment.data().uid);
    }
    return uids.filter((v, i, a) => a.indexOf(v) === i);  // remove duplicate
  }


  async function removeCommentSubscriber(uids, topic) {
    const _uids = [];
    // const users = await admin.database().ref('user-settings').child('topic').orderByChild(topic).equalTo(true).get();
    // console.log(users);

    const getTopicsPromise = [];
    for(let uid of uids ) {
        getTopicsPromise.push( admin.database().ref('user-settings').child(uid).child('topic').get());
        // getTopicsPromise.push( admin.database().ref('user-settings').child(uid).child('topic').once('value'));
    } 
    const result = await Promise.all(getTopicsPromise);
    for(let i in result) { 
      const v = result[i].val();
      if(v['newCommentUnderMyPostOrCOmment'] != null && v['newCommentUnderMyPostOrCOmment'] == true && (v[topic] == null || v[topic] == false)) {
        _uids.push(uids[i]);
      }
    }  
    return _uids;
  }

  async function getTokensFromUid(uids) {
    const _tokens = [];
    const getTokensPromise = [];
    for(let u of uids) {
      getTokensPromise.push(admin.firestore().collection('message-tokens').where('uid', '==', u).get());
    }

    const result = await Promise.all(getTokensPromise);
    for(let tokens of result) { 
      if(tokens.size == 0) continue;
      for( let doc of tokens.docs) {
        _tokens.push(doc.id);
      }
    }   
    return _tokens;
  }




// message-token onCreate it will subscribe to `defaultTopic`.    
// exports.subscribeToMainTopicOnTokenCreate = functions
//     .region("asia-northeast3")
//     .firestore
//     .document("/message-tokens/{token}")
//     .onCreate((snapshot) => {
//         return admin.messaging().subscribeToTopic('defaultTopic', snapshot.data().id);
//     });


function indexPost(id, data) {
    console.log('--> post data; ', data);
    const _data = {
        id: id,
        uid: data.uid,
        title: data.title,
        category: data.category,
        content: data.content,
        timestamp: data.timestamp ?? Date.now(),
    };

    return Axios.post(
        "http://wonderfulkorea.kr:7700/indexes/posts/documents",
        _data
    );
}

function indexComment(id, data) {
  console.log('--> comment data; ', data);
  /// id, uid, parentId, content, timestamp

  const _data = {
      id: id,
      uid: data.uid,
      postId: data.postId,
      content: data.content,
      timestamp: data.timestamp ?? Date.now(),
  };
  return Axios.post(
      "http://wonderfulkorea.kr:7700/indexes/comments/documents",
      _data
  );

}

// Index when a post is created
//
// meilisearchCreatePostIndex({ category: 'discussion', uid: 'user_ccc', title: 'I post on discussion', content: 'Discussion', timestamp: '12 February 2022 at 17:44:19 UTC+8' })
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

exports.meilisearchCreateCommentIndex = functions
    .region("asia-northeast3").firestore
    .document("/comments/{commentId}")
    .onCreate((snap, context) => {
        return indexComment(context.params.postId, snap.data());
    });

exports.meilisearchUpdatePostIndex = functions
  .region("asia-northeast3").firestore
  .document("/comments/{commentId}")
  .onUpdate((change, context) => {
      // const oldValue = change.before.data();
      const newValue = change.after.data();
      return indexComment(context.params.postId, newValue);
  });