"use strict";

const admin = require("firebase-admin");
// const utils = require("../functions/utils");

// initialize the firebase
if (!admin.apps.length) {
  const serviceAccount = require("../firebase-admin-sdk-key.json");
  const json = require("../database-url.json");
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: json.databaseURL,
  });
}

// get firestore
const db = admin.firestore();

// get real time database
const rdb = admin.database();

updateProfileReady();

async function updateProfileReady() {
  const snapshot = await rdb.ref("users").once("value");
  const docs = snapshot.val();
  for (let key in docs) {
    console.log(
      "user: ",
      key,
      ", profileReady: ",
      docs[key].profileReady,
      ", registeredAt: ",
      docs[key].registeredAt
    );
    if (docs[key].profileReady === true) {
      let registeredAt = 0;
      if (docs[key].registeredAt) registeredAt = docs[key].registeredAt;

      await rdb
        .ref("users")
        .child(key)
        .child("profileReady")
        .set(90000000000000 + registeredAt);
    }
  }
}
