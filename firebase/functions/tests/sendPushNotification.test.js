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

// get real time database
const rdb = admin.database();

const validToken1 =
  "djwdebPrQtm_u2N7jIygx3:APA91bHYJo7-bnbxHicRQOtT0kyyN42MRBaCk8WmrUFhsJhlHgI-xqgHzKnSL_ntr8WdvbeZCxwQLovATw972DzRAzlQ0H0Kx_iihU54VdP13cqYfaIX8DQGHnpbpW_OtWHutvD-MqeX";
const validToken2 =
  "dT9S0cPbQ3OSRCbB8EG9li:APA91bHKVGQneklgn1baHTlE4xufYSdNrqt59JB4vRTxPYYjoGyiHhFkxBhYyE2sG6DFOCZ7oWEmne9GLKQje5YYCsLWIevg6W7kLQYl9gDERH6-s1Q_1C5vn5XCZf1mhdBr_KYPVKvX";

// This must come after initlization

const test = require("../test");
const lib = require("../lib");

describe("SendPushNotification test  ####################################", () => {
  // it("send message to topic", async () => {
  //   const testTopic = "sendingToTestTopic";

  //   await admin.messaging().subscribeToTopic(validToken1, testTopic);
  //   try {
  //     const re = await lib.sendMessageToTopic({
  //       topic: testTopic,
  //       title: "push title test via topic 1",
  //       body: "push body test via topic 1",
  //     });
  //     console.log(re);
  //     if (re.code == "success") {
  //       assert.ok("sending push notification was success.");
  //       assert.ok(re.result != null, "messageId must exist");
  //     } else assert.fail("failed on sending message to default topic");
  //   } catch (e) {
  //     console.log(e);
  //     assert.fail("send push notification should succeed." + e);
  //   }
  // });

  // it("send message to token", async () => {
  //   try {
  //     const re = await lib.sendMessageToTokens({
  //       tokens: "invalidToken-this-is-not-valid",
  //       title: "push title test via token 1",
  //       body: "push body test via token 1",
  //     });
  //     if (re.code == "success") assert.fail("sending push notification should fail.");
  //     else assert.ok("failed on sending message to token");
  //   } catch (e) {
  //     assert.ok("send push notification should fail.");
  //   }

  //   try {
  //     const re = await lib.sendMessageToTokens({
  //       tokens: validToken1,
  //       title: "push title test via token 1",
  //       body: "push body test via token 1",
  //     });
  //     if (re.code == "success") assert.ok("sending push notification was success.");
  //     else assert.fail("failed on sending message to topic");
  //   } catch (e) {
  //     assert.fail("send push notification should succeed::." + e);
  //   }

  //   try {
  //     const re = await lib.sendMessageToTokens({
  //       tokens: [validToken1, validToken2, "invalidtoken"],
  //       title: "push title test via multiple tokens",
  //       body: "push body test via multiple tokens",
  //     });
  //     if (re.code == "success") {
  //       assert.ok("sending push notification was success.");
  //       assert.ok(re.result.success == 2);
  //       assert.ok(re.result.error == 1);
  //     } else assert.fail("failed on sending messaging to list token");
  //   } catch (e) {
  //     assert.fail("send push notification should succeed.");
  //   }

  //   try {
  //     const re = await lib.sendMessageToTokens({
  //       tokens: validToken1 + "," + validToken2 + "," + "invalidtoken",
  //       title: "push title test via multiple tokens as string",
  //       body: "push body test via multiple tokens  as string",
  //     });
  //     if (re.code == "success") {
  //       assert.ok("sending push notification was success.");
  //       assert.ok(re.result.success == 2);
  //       assert.ok(re.result.error == 1);
  //     } else assert.fail("failed on sending message to string tokens");
  //   } catch (e) {
  //     assert.fail("send push notification should succeed.");
  //   }
  // });

  it("send message to user", async () => {
    const userA = "sendMessaegUserA";
    const userB = "sendMessaegUserB";
    await test.createTestUser(userA);
    await test.createTestUser(userB);

    const tokenUpdates = [];
    tokenUpdates.push(rdb.ref("message-tokens").child(validToken1).set({uid: userA}));
    tokenUpdates.push(rdb.ref("message-tokens").child(validToken2).set({uid: userB}));
    await Promise.all(tokenUpdates);
    try {
      const re = await lib.sendMessageToUsers({
        uids: userA,
        title: "push title 1",
        body: "push body 1",
      });
      if (re.code == "success") assert.ok("sending push notification was success.");
      else assert.fail("failed on sending message to default topic");
    } catch (e) {
      console.log(e);
      assert.fail("send push notification to user 1 must success." + e);
    }

    try {
      const re = await lib.sendMessageToUsers({
        uids: [userA, userB],
        title: "push title 1",
        body: "push body 1",
      });
      if (re.code == "success") {
        assert.ok("sending push notification was success.");
        assert.ok(re.result.success == 2, "sending push notification was success.");
      } else assert.fail("failed on sending message to default topic");
    } catch (e) {
      console.log(e);
      assert.fail("send push notification to user 2 must success."  + e);
    }

    try {
      const re = await lib.sendMessageToUsers({
        uids: userA + "," + userB + "," + "abcd",
        title: "push title 1",
        body: "push body 1",
      });
      if (re.code == "success") {
        assert.ok("sending push notification was success.");
        assert.ok(re.result.success == 2, "sending push notification 2 success.");
        assert.ok(re.result.error == 0, "sending push notification 0 error.");
      } else assert.fail("failed on sending message to default topic");
    } catch (e) {
      console.log(e);
      assert.fail("send push notification  to user 3 must success."  +e);
    }
  });
});
