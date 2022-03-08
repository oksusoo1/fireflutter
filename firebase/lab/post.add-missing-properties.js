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
  const postCol = db.collection("posts");
  const snapshot = await postCol.get();
  if (snapshot.empty) {
    console.log("No matching documents.");
    return;
  }

  snapshot.forEach((doc) => {
    const data = doc.data();
    if (typeof data.noOfComments !== "undefined" && typeof data.deleted !== "undefined") {
      console.log("[O] ", doc.id, data.noOfComments, data.deleted);
    } else {
      console.log("[X] ", doc.id, data.noOfComments, data.deleted);
      postCol.doc(doc.id).update({ noOfComments: 0, deleted: false });
    }
  });
}
