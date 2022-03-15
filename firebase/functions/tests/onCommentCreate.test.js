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

// const test = require("../test");
const lib = require("../lib");

describe("Comment Create Test ~~~~~~~~~~~~~~~~", () => {
  it("on comment create test", async () => {
    try {
      const res = await lib.sendMessageOnCommentCreate(
          "commentTest1Id1647253281083",
          {
            content: "comment from shell",
            postId: "postTestId",
            parentId: "postTestId",
            uid: "userB",
          },
      );
      console.log(res);
      assert.ok(res.topicResponse != null, "topic must be success");
      assert.ok(res.tokenResponse != null, "topic must be success");
    } catch (e) {
      assert.fail("sendMessageOnCommentCreate::error:: " + e);
    }
  });
});
