"use strict";
const mocha = require("mocha");
const describe = mocha.describe;
const it = mocha.it;

// const assert = require("assert");
const admin = require("firebase-admin");

// initialize the firebase
if (!admin.apps.length) {
  const serviceAccount = require("../../withcenter-test-project.adminKey.json");
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL:
      "https://withcenter-test-project-default-rtdb.asia-southeast1.firebasedatabase.app/",
    storageBucket: "withcenter-test-project.appspot.com",
  });
}

// get firestore
const db = admin.firestore();

// This must come after initlization
const utils = require("../utils");

describe("getTimestamp test", () => {
  it("firestore timestamp", () => {
    console.log(db.Timestamp);
  });
});
