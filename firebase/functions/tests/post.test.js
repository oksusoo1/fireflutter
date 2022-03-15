"use strict";

const mocha = require("mocha");
const describe = mocha.describe;
const it = mocha.it;

const assert = require("assert");

// const functions = require("firebase-functions");
const admin = require("firebase-admin");

// initialize the firebase
if (!admin.apps.length) {
  const serviceAccount = require("../../firebase-admin-sdk-key.json");
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL:
      "https://withcenter-test-project-default-rtdb.asia-southeast1.firebasedatabase.app/",
  });
}
// This must come after initlization

const test = require("../test");
const lib = require("../lib");

describe("Post ~~~~~~~~~~~~~~~~", () => {
  it("Post test", async () => {

    const userA = "postTestUserA";
    
    // userA create parent post
    const postTestId = "postTestId";
    await test.createPost({
      category: {id: "test"},
      post: {
        title: userA + "post test title",
        content: "post test content",
        uid: userA,
        id: postTestId,
      },
    });

    try {
        const post = await lib.getPost(postTestId);
        assert.ok(post.data().uid == userA, "post create must be success");
    } catch (e) {
        assert.fail("getting post" + e);
    }

  });

});