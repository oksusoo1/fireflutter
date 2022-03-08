"use strict";
const mocha = require("mocha");
const describe = mocha.describe;
const it = mocha.it;

const assert = require("assert");
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

// get firestore
// const db = admin.firestore();

const rdb = admin.database();

const test = require("../test");
const lib = require("../lib");

describe("lib retrieveToken test  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", () => {
  it("retrieve push tokens", async () => {
    const userA = "retrieveTokenUserA";
    const userB = "retrieveTokenUserB";
    await test.createTestUser(userA);
    await test.createTestUser(userB);
    const tokenUpdates = [];
    tokenUpdates.push(rdb.ref("message-tokens").child("fakeToken1").set({uid: userA}));
    tokenUpdates.push(rdb.ref("message-tokens").child("fakeToken2").set({uid: userA}));
    tokenUpdates.push(rdb.ref("message-tokens").child("fakeToken3").set({uid: userA}));
    tokenUpdates.push(rdb.ref("message-tokens").child("fakeToken4").set({uid: userB}));
    await Promise.all(tokenUpdates);

    try {
      const re = await lib.getTokensFromUids(userA);
      if (re.length == 3) assert.ok("3 token must exist");
      else assert.fail("3 token must exist, got: " + re.length);
    } catch (e) {
      assert.fail("reteieve 3 tokens. error: " + e);
    }

    try {
      const res = await lib.getTokensFromUids(userA + "," + userB);
      if (res.length == 4) assert.ok("3 token must exist");
      else assert.fail("4 token must exist, got: " + res.length);
    } catch (e) {
      assert.fail("reteieve 4 tokens. error: " + e);
    }

    try {
      const res = await lib.getTokensFromUids("userAB" + "," + userB);
      if (res.length == 1) assert.ok("1 token must exist");
      else assert.fail("1 token must exist, got: " + res.length);
    } catch (e) {
      assert.fail("reteieve 1 tokens. error: " + e);
    }
  });
});
