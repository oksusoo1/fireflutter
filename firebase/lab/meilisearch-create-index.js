"use strict";

const admin = require("firebase-admin");
const Axios = require("axios");
const utils = require("../functions/utils");

// initialize the firebase
if (!admin.apps.length) {
  const serviceAccount = require("../firebase-admin-sdk-key.json");
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://wonderful-korea-default-rtdb.asia-southeast1.firebasedatabase.app/",
  });
}

// get firestore
const db = admin.firestore();

// get real time database
const rdb = admin.database();

const indexUid = process.argv[2];
if (!indexUid) {
  console.log("[NOTICE]: Please provide an index. It's either posts, comments, users.");
  process.exit(-1);
}

if (indexUid == "posts" || indexUid == "comments") {
  forumIndexing(indexUid);
}

/// User index document
if (indexUid == "users") {
  userIndexing();
}

async function forumIndexing(indexUid) {
  /// Read documents (exclude deleted documents).
  const col = db.collection(indexUid);

  const docs = await col.get();

  /// Nothing to index.
  if (docs.empty) {
    console.log("[NOTICE]: No documents found under " + indexUid + " index.");
    return;
  }

  /// Print total size/number of document collection.
  console.log("re-indexing " + docs.size + " documents under " + indexUid + " index.");
  for (const doc of docs.docs) {
    const data = doc.data();

    ///
    if (data.deleted) continue;

    /// Forum index document.
    console.log("[INDEXING]: " + doc.id, data.title ?? data.content);
    const _data = {
      id: doc.id,
      uid: data.uid,
      content: data.content ?? "",
      files: data.files && data.files.length ? data.files.join(",") : "",
      createdAt: utils.getTimestamp(data.createdAt),
      updatedAt: utils.getTimestamp(data.updatedAt),
    };

    if (indexUid == "comments") {
      _data.postId = data.postId;
      _data.parentId = data.parentId;
    } else {
      _data.title = data.title ?? "";
    }

    const promises = [];

    _data.content = utils.removeHtmlTags(_data.content);
    promises.push(
      Axios.post("http://wonderfulkorea.kr:7700/indexes/" + indexUid + "/documents", _data)
    );
    promises.push(
      Axios.post("http://wonderfulkorea.kr:7700/indexes/posts-and-comments/documents", _data)
    );
    await Promise.all(promises);
  }
}

async function userIndexing() {
  const col = rdb.ref("users");
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
}
