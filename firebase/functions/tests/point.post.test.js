"use strict";

const mocha = require("mocha");
const describe = mocha.describe;
const it = mocha.it;

const assert = require("assert");
const admin = require("firebase-admin");

// console.log("admin.apps.length; ", admin.apps.length);

// initialize the firebase
if (!admin.apps.length) {
  const serviceAccount = require("../../firebase-admin-sdk-key.json");
  // console.log("service account; ", serviceAccount);

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL:
      "https://withcenter-test-project-default-rtdb.asia-southeast1.firebasedatabase.app/",
  });
}

const lib = require("../lib"); // admin must be initlized first.
// const test = require("../test");
const utils = require("../utils");

const uid = "uid-" + utils.getTimestamp();

describe("Point test; " + uid, () => {
  it("Post create event test - uid: " + uid, async () => {
    // Get my point first,
    const startingPoint = await lib.getMyPoint(uid);

    console.log("startingPoint; ", startingPoint);

    // Make the time check to 3 seconds.
    lib.randomPoint[lib.pointEvent.postCreate].within = 3;

    const postId = "post-id-" + utils.getTimestamp();

    // 1. Generage random point for post create
    // 2. Check point change
    // 3. assert point change. data.point is the amount of generated point.
    const ref = await lib.postCreatePoint({uid: uid}, {params: {postId: postId}});
    assert.ok(ref);
    const data = (await ref.get()).val();
    const pointAfterCreate = await lib.getMyPoint(uid);
    assert.ok(startingPoint + data.point === pointAfterCreate);

    // After 4 seconds.
    await lib.delay(4000);

    // Expect failure.
    // Test with same post id. it will not change point. since it is going to be an update.
    const updateRef = await lib.postCreatePoint({uid: uid}, {params: {postId: postId}});
    assert.ok(updateRef === null);

    // Expect success.
    // There will be two point event histories.
    // Do point event for post create with different post id.
    const ref2 = await lib.postCreatePoint({uid: uid}, {params: {postId: postId + "2"}});
    assert.ok(ref2);
    const data2 = (await ref2.get()).val();
    const pointAfterCreate2 = await lib.getMyPoint(uid);
    assert.ok(startingPoint + data.point + data2.point === pointAfterCreate2);

    // Expect failure.
    // After 1.5 seconds later, do it again and expect failure since `within` time has not passed.
    await lib.delay(1500);
    const ref3 = await lib.postCreatePoint({uid: uid}, {params: {postId: postId + "3"}});
    assert.ok(ref3 === null);
    const pointAfterCreate3 = await lib.getMyPoint(uid);
    assert.ok(startingPoint + data.point + data2.point === pointAfterCreate3);
  });
});
