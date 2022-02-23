"use strict";
const mocha = require("mocha");
const describe = mocha.describe;
const it = mocha.it;

const assert = require("assert");
const admin = require("firebase-admin");
// initialize the firebase
if (!admin.apps.length) {
  const serviceAccount = require("../../withcenter-test-project.adminKey.json");
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://withcenter-test-project-default-rtdb.asia-southeast1.firebasedatabase.app/",
  });
}


// get firestore
const db = admin.firestore();

const validToken1 = "eiG6CUPQS66swAIEOakM60:APA91bGj4tjLswDzSAWz72onE_Tv50TYrI2I3hRXu-0RDJOa2c71elDDnL5gfrcZY5PfppRgbl2hC_R2A4SzstPu___yR9DzB1YoIDnJ-IITVxoqIJ_2gBLQOl9MGJ7_vRFZNmUfIVHD";
const validToken2 = "ecw_jCq6TV273wlDMeaQRY:APA91bF8GUuxtjlpBf7xI9M4dv6MD74rb40tpDedeoJ9w1TYi-9TmGCrt862Qcrj4nQifRBrxS60AiBSQW8ynYQFVj9Hkrd3p-w9UyDscLncNdwdZNXpqRgBR-LmSeZIcNBejvxjtfW4";



// This must come after initlization
const lib = require("../lib");

describe("SendPushNotification test  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", () => {
  it("send message to topic", async () => {
    const testTopic = "sendingToTestTopic";

    await admin.messaging().subscribeToTopic(validToken1, testTopic);
    try {
      const re = await lib.sendMessageToTopic({
        topic: testTopic,
        title: "push title test via topic 1",
        body: "push body test via topic 1",
      });
      if ( re.code == "success") {
        assert.ok("sending push notification was success.");
        assert.ok(re.result.messageId != null, "messageId must exist");
      } else assert.fail("failed on sending message to default topic");
    } catch (e) {
      assert.fail("send push notification should succeed.");
    }
  });

  it("send message to token", async () => {
    try {
      const re = await lib.sendMessageToTokens({
        tokens: "invalidToken-this-is-not-valid",
        title: "push title test via token 1",
        body: "push body test via token 1",
      });
      if ( re.code == "success") assert.fail("sending push notification should fail.");
      else assert.ok("failed on sending message to token");
    } catch (e) {
      assert.ok("send push notification should fail.");
    }

    try {
      const re = await lib.sendMessageToTokens({
        tokens: validToken1,
        title: "push title test via token 1",
        body: "push body test via token 1",
      });
      if ( re.code == "success") assert.ok("sending push notification was success.");
      else assert.fail("failed on sending message to topic");
    } catch (e) {
      assert.fail("send push notification should succeed::." + e);
    }

    try {
      const re = await lib.sendMessageToTokens({
        tokens: [validToken1, validToken2, "invalidtoken"],
        title: "push title test via multiple tokens",
        body: "push body test via multiple tokens",
      });
      if ( re.code == "success") {
        assert.ok("sending push notification was success.");
        assert.ok(re.result.success == 2);
        assert.ok(re.result.error == 1);
      } else assert.fail("failed on sending messaging to list token");
    } catch (e) {
      assert.fail("send push notification should succeed.");
    }

    try {
      const re = await lib.sendMessageToTokens({
        tokens: validToken1 + "," + validToken2 + "," + "invalidtoken",
        title: "push title test via multiple tokens as string",
        body: "push body test via multiple tokens  as string",
      });
      if ( re.code == "success") {
        assert.ok("sending push notification was success.");
        assert.ok(re.result.success == 2);
        assert.ok(re.result.error == 1);
      } else assert.fail("failed on sending message to string tokens");
    } catch (e) {
      assert.fail("send push notification should succeed.");
    }
  });


  it("send message to user", async () => {
    const userA = "sendMessaegUserA";
    const userB = "sendMessaegUserB";
    await lib.createTestUser(userA);
    await lib.createTestUser(userB);

    const tokenUpdates = [];
    tokenUpdates.push( db.collection("message-tokens").doc(validToken1).set({uid: userA}));
    tokenUpdates.push( db.collection("message-tokens").doc(validToken2).set({uid: userB}));
    await Promise.all(tokenUpdates);
    try {
      const re = await lib.sendMessageToUsers({
        uids: userA,
        title: "push title 1",
        body: "push body 1",
      });
      if ( re.code == "success") assert.ok("sending push notification was success.");
      else assert.fail("failed on sending message to default topic");
    } catch (e) {
      assert.fail("send push notification should succeed.");
    }
    try {
      const re = await lib.sendMessageToUsers({
        tokens: [userA, userA],
        title: "push title 1",
        body: "push body 1",
      });
      if ( re.code == "success") assert.ok("sending push notification was success.");
      else assert.fail("failed on sending message to default topic");
    } catch (e) {
      assert.fail("send push notification should succeed.");
    }
  });
});
