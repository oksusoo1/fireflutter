"use strict";
const mocha = require("mocha");
const describe = mocha.describe;
const it = mocha.it;

// const assert = require("assert");
const admin = require("firebase-admin");

// initialize the firebase
if (!admin.apps.length) {
  const serviceAccount = require("../../firebase-admin-sdk-key.json");
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL:
      "https://withcenter-test-project-default-rtdb.asia-southeast1.firebasedatabase.app/",
    storageBucket: "withcenter-test-project.appspot.com",
  });
}

// get firestore
// const db = admin.firestore();

// This must come after initlization
const test = require("../test");
const utils = require("../utils");

describe("getTimestamp test", () => {
  it("firestore timestamp", async () => {
    const ref = await test.createPost({
      category: "test",
      post: {},
    });
    const data = (await ref.get()).data();

    console.log(utils.getTimestamp());
    console.log(utils.getTimestamp(data.createdAt));
  });
});
