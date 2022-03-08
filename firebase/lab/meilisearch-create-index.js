"use strict";

const admin = require("firebase-admin");

// initialize the firebase
if (!admin.apps.length) {
  const serviceAccount = require("../firebase-admin-sdk-key.json");
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    // rtdb ... url...
  });
}

// get firestore
const db = admin.firestore();

const { MeiliSearch } = require("meilisearch");

const client = new MeiliSearch({
  host: "http://wonderfulkorea.kr:7700",
  apiKey: "",
});

runFunction();

async function runFunction() {
  const postCol = db.collection("posts");
  const postSnapshot = await postCol.get();
  if (postSnapshot.empty) {
    return;
  }

  for (const postData of postSnapshot.docs) {
    const post = postData.data();
    console.log("- ", post.title, post.files.length);

    const commentCol = db.collection("comments").where("postId", "==", postData.id);

    const commentSnapshot = await commentCol.get();

    if (commentSnapshot.size > 0) {
      for (const commentDoc of commentSnapshot.docs) {
        const comment = commentDoc.data();
        console.log("  - ", comment.content, comment.files.length);
      }
    }
  }
}
