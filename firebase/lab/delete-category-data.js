"use strict";

const admin = require("firebase-admin");

// initialize the firebase
if (!admin.apps.length) {
  const serviceAccount = require("../firebase-admin-sdk-key.json");
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

// get firestore
const db = admin.firestore();

runFunction();

async function runFunction() {
  const postCol = db.collection("posts").where("category", "==", process.argv[2]);
  const snapshot = await postCol.get();
  if (snapshot.empty) {
    return;
  }

  for (const doc of snapshot.docs) {
    const post = doc.data();
    console.log("- ", post.title, post.files.length);

    const commentCol = db.collection("comments").where("postId", "==", doc.id);

    const commentSnapshot = await commentCol.get();

    if (commentSnapshot.size > 0) {
      for (const commentDoc of commentSnapshot.docs) {
        const comment = commentDoc.data();
        console.log("  - ", comment.content, comment.files.length);
        await db.collection("comments").doc(commentDoc.id).delete();
      }
    }

    await db.collection("posts").doc(doc.id).delete();
  }
}
