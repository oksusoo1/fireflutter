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
                title: snapshot.data().title ?? '',
                body: snapshot.data().content ?? '',
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
      const ancestors_uid = await getCommentAncestors(context.params.commentId, snapshot.data().uid);
      
      // add the post uid if the comment author is not the post author
      if(post.data().uid != snapshot.data().uid && !ancestors_uid.includes(post.data().uid)) {
        ancestors_uid.push(post.data().uid);
      }

      // remove subcriber uid but want to get notification under their post/comment
      const user_uids = await removeUserWithTopicAndNewCommentUnderMyPostOrCommentSubscriber(ancestors_uid, topic);


      // get users tokens
      const tokens = await getTokensFromUid(user_uids);

      if(tokens.length == 0) return [];


      // chuck token to 1000 https://firebase.google.com/docs/cloud-messaging/send-message#send-to-individual-devices
      // You can send messages to up to 1000 devices in a single request. 
      // If you provide an array with over 1000 registration tokens, 
      // the request will fail with a messaging/invalid-recipient error.
      const chunks = chunk(tokens, 1000);

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

  // get comment ancestor by getting parent comment until it reach the root comment
  // return the uids of the author
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

  // check the uids if they are subscribe to topic and also want to get notification under their post/comment
  async function removeUserWithTopicAndNewCommentUnderMyPostOrCommentSubscriber(uids, topic) {
    const _uids = [];
    const getTopicsPromise = [];
    for(let uid of uids ) {
        getTopicsPromise.push( admin.database().ref('user-settings').child(uid).child('topic').get());
        // getTopicsPromise.push( admin.database().ref('user-settings').child(uid).child('topic').once('value'));  // same result above
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

  function chunk(arr, chunkSize) {
    if (chunkSize <= 0) throw "Invalid chunk size";
    var R = [];
    for (var i=0,len=arr.length; i<len; i+=chunkSize)
      R.push(arr.slice(i,i+chunkSize));
    return R;
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


    console.log('--> data; ', data);

    const _data = {
        id: id,
        uid: data.uid,
        title: data.title,
        category: data.category,
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
