"use strict";

const admin = require("firebase-admin");

// initialize the firebase
if (!admin.apps.length) {
  const serviceAccount = require("../wonderful-korea-firebase-admin-sdk-key.json");
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL:
      "https://withcenter-test-project-default-rtdb.asia-southeast1.firebasedatabase.app/",
  });
}

console.log(admin.auth());
