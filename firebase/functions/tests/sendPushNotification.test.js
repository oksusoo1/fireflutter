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

// This must come after initlization
const lib = require("../lib");

describe("SendPushNotification test", () => {
  it("send message to default topic", async () => {
    try {
      const re = await lib.sendPushNotification({
        topic: "defaultTopic",
        title: "push title 1",
        body: "push body 1",
      });
      if ( re.code == "success") assert.ok("sending push notification was success.");
      else assert.fail("failed on seding messaing to default topic");
    } catch (e) {
      assert.fail("send push notification should succeed.");
    }
  });
});
