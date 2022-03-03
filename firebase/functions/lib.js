/**
 * @file lib.js
 */
"use strict";

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const Axios = require("axios");
const utils = require("./utils");
const ref = require("./reference");

// const {MeiliSearch} = require("meilisearch");

// get firestore
const db = admin.firestore();

// get real time database
const rdb = admin.database();

const auth = admin.auth();

const delay = (time) => new Promise((res) => setTimeout(res, time));

const commentNotification = "newCommentUnderMyPostOrComment";

/**
 * Returns a query of getting all categories.
 *
 * @return query of categories
 */
function getCategories() {
  return db.collection("categories").get();
}

/**
 * Returns the number of categories.
 *
 * @return no of categories
 */
async function getSizeOfCategories() {
  const snapshot = await getCategories();
  return snapshot.size;
}

/**
 * Returns post data
 *
 * @param {*} id post id
 * @returns Returns the post document data
 */
function getPost(id) {
  return admin.firestore().collection("posts").doc(id).get();
}


/**
 * Creates or update a user document index.
 * 
 * @param {*} id user id.
 * @param {*} data user data to index.
 * @returns promise
 */
 async function indexUserDocument(id, data) {
  const _data = {
    id: id,
    gender: data.gender ?? '',
    firstname: data.firstName ?? '',
    middlename: data.middleName ?? '',
    lastname: data.lastName ?? '',
    photoUrl: data.photoUrl ?? '',
    registeredAt: utils.getTimestamp(data.registeredAt),
    updatedAt: utils.getTimestamp(data.updatedAt),
  };

  // return Axios.post("https://wonderfulkorea.kr:4431/index.php?api=post/record", _data)
  return Axios.post("http://wonderfulkorea.kr:7700/indexes/users/documents", _data)
}

/**
 * Deletes user document index.
 * 
 * @param {*} id user id to delete.
 * @returns promise
 */
async function deleteIndexedUserDocument(id) {
  return Axios.delete("http://wonderfulkorea.kr:7700/indexes/users/documents/" + id);
}

/**
 * Indexes a post
 *
 * @param {*} id post id
 * @param {*} data post data to index
 * @returns promise
 */
async function indexPostDocument(id, data) {
  const _data = {
    id: id,
    uid: data.uid,
    title: data.title ?? "",
    category: data.category,
    content: data.content ?? "",
    files: data.files && data.files.length ? data.files.join(",") : "",
    noOfComments: data.noOfComments ?? 0,
    deleted: data.deleted ? "Y" : "N",
    createdAt: utils.getTimestamp(data.createdAt),
    updatedAt: utils.getTimestamp(data.updatedAt),
  };

  const promises = [];

  promises.push(Axios.post("https://wonderfulkorea.kr:4431/index.php?api=post/record", _data));

  _data.content = utils.removeHtmlTags(_data.content);
  promises.push(Axios.post("http://wonderfulkorea.kr:7700/indexes/posts/documents", _data));
  promises.push(indexForumDocument(_data));

  return Promise.all(promises);
}

async function indexCommentDocument(id, data) {
  const _data = {
    id: id,
    uid: data.uid,
    postId: data.postId,
    parentId: data.parentId,
    content: data.content,
    files: data.files && data.files.length ? data.files.join(",") : "",
    createdAt: utils.getTimestamp(data.createdAt),
    updatedAt: utils.getTimestamp(data.updatedAt),
  };

  const promises = [];

  promises.push(Axios.post("https://wonderfulkorea.kr:4431/index.php?api=post/record", _data));

  _data.content = utils.removeHtmlTags(_data.content);
  promises.push(Axios.post("http://wonderfulkorea.kr:7700/indexes/comments/documents", _data));
  promises.push(indexForumDocument(_data));

  return Promise.all(promises);
}

function indexForumDocument(data) {
  return Axios.post("http://wonderfulkorea.kr:7700/indexes/posts-and-comments/documents", data);
}

async function deleteIndexedPostDocument(id) {
  const promises = [];
  promises.push(
    Axios.post("https://wonderfulkorea.kr:4431/index.php?api=post/delete", {
      id: id,
    })
  );
  promises.push(Axios.delete("http://wonderfulkorea.kr:7700/indexes/posts/documents/" + id));
  promises.push(deleteIndexedForumDocument(id));
  return Promise.all(promises);
}

async function deleteIndexedCommentDocument(id) {
  const promises = [];
  promises.push(
    Axios.post("https://wonderfulkorea.kr:4431/index.php?api=post/delete", {
      id: id,
    })
  );
  promises.push(Axios.delete("http://wonderfulkorea.kr:7700/indexes/comments/documents/" + id));
  promises.push(deleteIndexedForumDocument(id));
  return Promise.all(promises);
}

async function deleteIndexedForumDocument(id) {
  return Axios.delete("http://wonderfulkorea.kr:7700/indexes/posts-and-comments/documents/" + id);
}

// get comment ancestor by getting parent comment until it reach the root comment
// return the uids of the author
async function getCommentAncestors(id, authorUid) {
  let comment = await ref.commentDoc(id).get();
  const uids = [];
  while (comment.data().postId != comment.data().parentId) {
    // if (comment.data().postId == comment.data().parentId ) break;
    comment = await ref.commentDoc(comment.data().parentId).get();
    if (comment.exists == false) continue;
    if (comment.data().uid == authorUid) continue; // skip the author's uid.
    uids.push(comment.data().uid);
  }
  return uids.filter((v, i, a) => a.indexOf(v) === i); // remove duplicate
}

// check the uids if they are subscribe to topic and also want to get notification under their post/comment
/**
 * Get ancestors who subscribed to 'comment notification' but removing those who subscribed to the topic.
 * @param {*} uids ancestors
 * @param {*} topic topic
 * @returns UIDs of ancestors.
 */
async function getCommentNotifyeeWithoutTopicSubscriber(uids, topic) {
  const _uids = [];
  const getTopicsPromise = [];
  for (const uid of uids) {
    getTopicsPromise.push(rdb.ref("user-settings").child(uid).child("topic").get());
  }
  const result = await Promise.all(getTopicsPromise);

  for (const i in result) {
    if (!result[i]) continue;
    const subscriptions = result[i].val();
    // / Get anscestors who subscribed to 'comment notification' and didn't subscribe to the topic.
    if (subscriptions[commentNotification] && !subscriptions[topic]) {
      _uids.push(uids[i]);
    }
  }

  return _uids;
}

async function getTokensFromUids(uids) {
  let _uids;
  if (typeof uids == "string") {
    _uids = uids.split(",");
  } else {
    _uids = uids;
  }

  const _tokens = [];
  const getTokensPromise = [];
  for (const u of _uids) {
    getTokensPromise.push(rdb.ref("message-tokens").orderByChild("uid").equalTo(u).get());
  }

  const result = await Promise.all(getTokensPromise);
  for (const i in result) {
    if (!result[i]) continue;
    const tokens = result[i].val();
    for (const token in tokens) {
      if (!token) continue;
      _tokens.push(token);
    }
  }

  return _tokens;
}

function chunk(arr, chunkSize) {
  if (chunkSize <= 0) return []; // don't throw here since it will not be catched.
  const R = [];
  for (let i = 0, len = arr.length; i < len; i += chunkSize) {
    R.push(arr.slice(i, i + chunkSize));
  }
  return R;
}

function error(errorCode, errorMessage) {
  throw new functions.https.HttpsError(errorCode, errorMessage);
}

async function sendMessageToTopic(query) {
  const payload = topicPayload(query);
  try {
    const res = await admin.messaging().send(payload);
    return { code: "success", result: res };
  } catch (e) {
    return { code: "error", message: e };
  }
}

async function sendMessageToTokens(query) {
  const payload = preMessagePayload(query);

  let _tokens;
  if (typeof query.tokens == "string") {
    _tokens = query.tokens.split(",");
  } else {
    _tokens = query.tokens;
  }

  try {
    const res = await sendingMessageToTokens(_tokens, payload);
    return { code: "success", result: res };
  } catch (e) {
    return { code: "error", message: e };
  }
}

async function sendMessageToUsers(query) {
  const payload = preMessagePayload(query);
  const tokens = await getTokensFromUids(query.uids);
  // console.log(tokens);
  try {
    const res = await sendingMessageToTokens(tokens, payload);
    return { code: "success", result: res };
  } catch (e) {
    return { code: "error", message: e };
  }
}

async function sendingMessageToTokens(tokens, payload) {
  if (tokens.length == 0) return [];

  // sending to device can be up to 1000 per batch but the downside is it cant set sound
  // chuck token to 1000 https://firebase.google.com/docs/cloud-messaging/send-message#send-to-individual-devices
  // You can send messages to up to 1000 devices in a single request.
  // If you provide an array with over 1000 registration tokens,
  // the request will fail with a messaging/invalid-recipient error.

  // / sendMulticast supports 500 token per batch only.
  const chunks = chunk(tokens, 500);

  const sendToDevicePromise = [];
  for (const c of chunks) {
    // Send notifications to all tokens.
    const newPayload = payload;
    newPayload["tokens"] = c;
    sendToDevicePromise.push(admin.messaging().sendMulticast(payload));
    // sendToDevicePromise.push(admin.messaging().sendToDevice(c, payload));
  }
  const sendDevice = await Promise.all(sendToDevicePromise);

  const tokensToRemove = [];
  let successCount = 0;
  let errorCount = 0;
  sendDevice.forEach((res, i) => {
    successCount += res.successCount;
    errorCount += res.failureCount;

    // For each message check if there was an error.
    // res.results.forEach((result, index) => { // sendToDevice response

    res.responses.forEach((result, index) => {
      const error = result.error;
      if (error) {
        // console.log(
        //     "Failure sending notification to",
        //     chunks[i][index],
        //     error,
        // );
        // Cleanup the tokens who are not registered anymore.
        if (
          error.code === "messaging/invalid-registration-token" ||
          error.code === "messaging/registration-token-not-registered"
        ) {
          tokensToRemove.push(rdb.ref("message-tokens").child(chunks[i][index]).remove());
        }
      }
    });
  });
  await Promise.all(tokensToRemove);
  return { success: successCount, error: errorCount };
}

function topicPayload(topic, query) {
  const payload = preMessagePayload(query);
  payload["topic"] = "/topics/" + topic;
  return payload;
}

function preMessagePayload(query) {
  return {
    data: {
      id: query.postId ? query.postId : "",
      type: query.type ? query.type : "",
      sender_uid: query.uid ? query.uid : "",
    },
    notification: {
      title: query.title ? query.title : "",
      body: query.body ? query.body : "",
    },
    android: {
      notification: {
        channelId: "PUSH_NOTIFICATION",
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
        sound: "default_sound.wav",
      },
    },
    apns: {
      payload: {
        aps: {
          sound: "default_sound.wav",
        },
      },
    },
  };
}

/**
 * Returns the storage path of the uploaded file.
 *
 * @param {*} url url of the uploaded file
 * @returns path of the uploaded file
 *
 * @usage Use this to get file from url.
 *
 * @example
 * admin.storage().bucket().file( getFilePathFromStorageUrl('https://...'))
 */
function getFilePathFromStorageUrl(url) {
  const token = url.split("?");
  const parts = token[0].split("/");
  return parts[parts.length - 1].replaceAll("%2F", "/");
}

async function updateFileParentId(id, data) {
  if (!data || !data.files || !data.files.length) {
    return;
  }
  const bucket = admin.storage().bucket();
  for (const url of data.files) {
    const f = bucket.file(getFilePathFromStorageUrl(url));
    console.log(await f.exists);
    await f.setMetadata({
      metadata: {
        id: id,
      },
    });
  }
}

async function isAdmin(context) {
  const doc = await db.collection("settings").doc("admins").get();
  const admins = doc.data();
  
  if (!admins[context.auth.uid]) return false;
  return true;
}

async function enableUser(data, context) {
  if(!isAdmin(context))
  return {
    code: "ERROR_YOU_ARE_NOT_ADMIN",
    message: "To manage user, you need to sign-in as an admin.",
  };
  await rdb.ref('users').child(context.auth.uid).update({ disabled: true })
  return auth.updateUser(data.uid, { disabled: true });
}

async function disableUser(data, context) {
  if(!isAdmin(context))
  return {
    code: "ERROR_YOU_ARE_NOT_ADMIN",
    message: "To manage user, you need to sign-in as an admin.",
  };
  await rdb.ref('users').child(context.auth.uid).update({ disabled: false })
  return auth.updateUser(data.uid, { disabled: false });
}

exports.delay = delay;
exports.getSizeOfCategories = getSizeOfCategories;
exports.getCategories = getCategories;

exports.getPost = getPost;

exports.indexComment = indexCommentDocument;
exports.indexPost = indexPostDocument;

exports.deleteIndexedPost = deleteIndexedPostDocument;
exports.deleteIndexedComment = deleteIndexedCommentDocument;

exports.getCommentAncestors = getCommentAncestors;
exports.getCommentNotifyeeWithoutTopicSubscriber = getCommentNotifyeeWithoutTopicSubscriber;
exports.getTokensFromUids = getTokensFromUids;
exports.chunk = chunk;

exports.error = error;

exports.sendMessageToTopic = sendMessageToTopic;
exports.sendMessageToTokens = sendMessageToTokens;
exports.sendMessageToUsers = sendMessageToUsers;
exports.preMessagePayload = preMessagePayload;
exports.topicPayload = topicPayload;

exports.sendingMessageToTokens = sendingMessageToTokens;

exports.updateFileParentId = updateFileParentId;
exports.enableUser = enableUser;
exports.disableUser = disableUser;
exports.indexUser = indexUserDocument;
exports.deleteIndexedUser = deleteIndexedUserDocument;
