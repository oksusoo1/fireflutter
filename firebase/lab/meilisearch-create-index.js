"use strict";

const admin = require("firebase-admin");
const Axios = require("axios");
const utils = require("../functions/utils");

// initialize the firebase
if (!admin.apps.length) {
  // const serviceAccount = require("../firebase-admin-sdk-key.json");
  const serviceAccount = require("../withcenter-test-project.adminKey.json");
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://withcenter-test-project-default-rtdb.asia-southeast1.firebasedatabase.app/",
  });
}

// get firestore
const db = admin.firestore();

// get real time database
const rdb = admin.database();

const indexUid = process.argv[2];
if (!indexUid) {
  console.log('[NOTICE]: Please provide an index. It\'s either posts, comments, users.');
  return;
}

if (indexUid == 'posts' || indexUid == 'comments') {
  forumIndexing(indexUid);
} 

/// User index document
if (indexUid == 'users') {
  userIndexing();
}

async function forumIndexing(indexUid) {
  /// Read documents (exclude deleted documents).
  const col = db.collection(indexUid);
  const docs = await col.where("deleted", "==", false).get();

  /// Nothing to index.
  if (docs.empty) {
    console.log("[NOTICE]: No documents found under " + indexUid + " index.");
    return;
  }

  /// Print total size/number of document collection.
  console.log("re-indexing " + docs.size + " documents under " + indexUid + " index.");
  for (const doc of docs.docs) {
    const data = doc.data();

    /// Forum index document.
    console.log("[INDEXING]: " + id);
    const _data = {
      id: id,
      uid: data.uid,
      content: data.content ?? "",
      files: data.files && data.files.length ? data.files.join(",") : "",
      createdAt: utils.getTimestamp(data.createdAt),
      updatedAt: utils.getTimestamp(data.updatedAt),
    };

    if (index == 'comments') {   
      _data.postId = data.postId;
      _data.parentId = data.parentId;
    }

    const promises = [];

    // promises.push(Axios.post("https://wonderfulkorea.kr:4431/index.php?api=post/record", _data));

    _data.content = utils.removeHtmlTags(_data.content);
    promises.push(Axios.post("http://wonderfulkorea.kr:7700/indexes/" + index + "/documents", _data));
    promises.push(Axios.post("http://wonderfulkorea.kr:7700/indexes/posts-and-comments/documents", data));
    await Promise.all(promises);
  }

  return void 0;
}


async function userIndexing() {
  const col = rdb.ref('users');
  const docs = await col.get();

  if (!docs.numChildren()) {
    console.log("No user documents to index.");
    return;
  } 
  
  console.log("Re-indexing " + docs.numChildren() + " of user documents.");
  for (const [key, value] of Object.entries(docs.val())) {
    const _data = {
      id: key,
      gender: value.gender ?? "",
      firstName: value.firstName ?? "",
      middleName: value.middleName ?? "",
      lastName: value.lastName ?? "",
      photoUrl: value.photoUrl ?? "",
    };
    await Axios.post("http://wonderfulkorea.kr:7700/indexes/users/documents", _data);
  }
  return;
}
