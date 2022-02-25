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

const delay = (time) => new Promise((res) => setTimeout(res, time));

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
      }),
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
      }),
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
async function removeTopicAndForumAncestorsSubscriber(uids, topic) {
  const _uids = [];
  const getTopicsPromise = [];
  for (const uid of uids) {
    getTopicsPromise.push(rdb.ref("user-settings").child(uid).child("topic").get());
    // getTopicsPromise.push( admin.database().ref('user-settings').child(uid).child('topic').once('value'));  // same result above
  }
  const result = await Promise.all(getTopicsPromise);

  for (const i in result) {
    if (!result[i]) continue;
    const v = result[i].val();
    if (
      v["newCommentUnderMyPostOrCOmment"] != null &&
      v["newCommentUnderMyPostOrCOmment"] == true &&
      (v[topic] == null || v[topic] == false)
    ) {
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
    getTokensPromise.push(
        admin.firestore().collection("message-tokens").where("uid", "==", u).get(),
    );
  }

  const result = await Promise.all(getTokensPromise);
  for (const tokens of result) {
    if (tokens.size == 0) continue;
    for (const doc of tokens.docs) {
      _tokens.push(doc.id);
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
  const payload = prePayload(query);

  try {
    const res = await admin.messaging().sendToTopic("/topics/" + query.topic, payload);
    return {code: "success", result: res};
  } catch (e) {
    return {code: "error", message: e};
  }
}

async function sendMessageToTokens(query) {
  const payload = prePayload(query);

  let _tokens;
  if (typeof query.tokens == "string") {
    _tokens = query.tokens.split(",");
  } else {
    _tokens = query.tokens;
  }

  try {
    const res = await sendingMessageToDevice(_tokens, payload);
    return {code: "success", result: res};
  } catch (e) {
    return {code: "error", message: e};
  }
}

async function sendMessageToUsers(query) {
  const payload = prePayload(query);
  const tokens = await getTokensFromUids(query.uids);
  console.log(tokens);
  try {
    const res = await sendingMessageToDevice(tokens, payload);
    return {code: "success", result: res};
  } catch (e) {
    return {code: "error", message: e};
  }
}

async function sendingMessageToDevice(tokens, payload) {
  if (tokens.length == 0) return [];

  // chuck token to 1000 https://firebase.google.com/docs/cloud-messaging/send-message#send-to-individual-devices
  // You can send messages to up to 1000 devices in a single request.
  // If you provide an array with over 1000 registration tokens,
  // the request will fail with a messaging/invalid-recipient error.
  const chunks = chunk(tokens, 1000);

  const sendToDevicePromise = [];
  for (const c of chunks) {
    // Send notifications to all tokens.
    sendToDevicePromise.push(admin.messaging().sendToDevice(c, payload));
  }
  const sendDevice = await Promise.all(sendToDevicePromise);

  const tokensToRemove = [];
  let successCount = 0;
  let errorCount = 0;
  sendDevice.forEach((response, i) => {
    // For each message check if there was an error.
    response.results.forEach((result, index) => {
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
          tokensToRemove.push(
              admin.firestore().collection("message-tokens").doc(chunks[i][index]).delete(),
          );
        }
        errorCount++;
      } else {
        // tokenOk.push({[chunks[i]]: 'ok' });
        successCount++;
      }
    });
  });
  await Promise.all(tokensToRemove);
  return {success: successCount, error: errorCount};
}

function prePayload(query) {
  return {
    notification: {
      title: query.title ? query.title : "",
      body: query.body ? query.title : "",
      clickAction: "FLUTTER_NOTIFICATION_CLICK",
      sound: "defaultSound.wav",
      channel: "PUSH_NOTIFICATION",
    },
    data: {
      id: query.postId ? query.postId : "",
      type: query.postId ? query.postId : "",
      sender_uid: query.uid ? query.uid : "",
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

exports.delay = delay;
exports.getSizeOfCategories = getSizeOfCategories;
exports.getCategories = getCategories;

exports.indexComment = indexCommentDocument;
exports.indexPost = indexPostDocument;

exports.deleteIndexedPost = deleteIndexedPostDocument;
exports.deleteIndexedComment = deleteIndexedCommentDocument;

exports.getCommentAncestors = getCommentAncestors;
exports.removeTopicAndForumAncestorsSubscriber = removeTopicAndForumAncestorsSubscriber;
exports.getTokensFromUids = getTokensFromUids;
exports.chunk = chunk;

exports.error = error;

exports.sendMessageToTopic = sendMessageToTopic;
exports.sendMessageToTokens = sendMessageToTokens;
exports.sendMessageToUsers = sendMessageToUsers;

exports.sendingMessageToDevice = sendingMessageToDevice;

exports.updateFileParentId = updateFileParentId;
