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

const uid = "point_test_" + utils.getTimestamp();
const signInUid = "point-test-1";

describe("Point test; uid - " + uid, () => {
  it("Register point event test", async () => {
    // / Do random point.
    const ref = await lib.userRegisterPoint({}, {params: {uid: uid}});
    assert.ok(ref !== null);
    const data = (await ref.get()).val();

    // / Check if success by getting the real doc data.
    const pointDoc = await lib.pointRegisterRef(uid).get();
    const pointDocData = pointDoc.val();

    assert.ok(data.timestamp === pointDocData.timestamp);

    // / Do random point again and see if it fails.
    const re = await lib.userRegisterPoint({}, {params: {uid: uid}});
    assert.ok(re === null);
  });

  it("Sign-in point event test - " + signInUid, async () => {
    // / Make the time check to 3 seconds.
    lib.randomPoint[lib.pointEvent.signIn].within = 3;
    console.log(lib.randomPoint);

    // / Do random point.
    const ref = await lib.userSignInPoint({}, {params: {uid: signInUid}});
    assert.ok(ref !== null);
    const data = (await ref.get()).val();

    console.log("data;", data);

    // / After 4 seconds.
    await lib.delay(4000);

    // / Do random point again. and should success.
    const refAgain = await lib.userSignInPoint({}, {params: {uid: signInUid}});
    assert.ok(refAgain !== null);
    const dataAgain = (await refAgain.get()).val();

    console.log("dataAgain;", dataAgain);

    // / After 1.5 seconds later, do it again and expect failure.
    await lib.delay(1500);
    const refError = await lib.userSignInPoint({}, {params: {uid: signInUid}});
    assert.ok(refError === null);
  });
});
