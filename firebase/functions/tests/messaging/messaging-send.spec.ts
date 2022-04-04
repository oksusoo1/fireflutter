import "mocha";

import { FirebaseAppInitializer } from "../firebase-app-initializer";

import { Messaging } from "../../src/classes/messaging";
import { expect } from "chai";

import { Test } from "../../src/classes/test";
import { Ref } from "../../src/classes/ref";
import { Utils } from "../../src/classes/utils";

new FirebaseAppInitializer();

const validToken1 =
  "dT9S0cPbQ3OSRCbB8EG9li:APA91bHKVGQneklgn1baHTlE4xufYSdNrqt59JB4vRTxPYYjoGyiHhFkxBhYyE2sG6DFOCZ7oWEmne9GLKQje5YYCsLWIevg6W7kLQYl9gDERH6-s1Q_1C5vn5XCZf1mhdBr_KYPVKvX";
const validToken2 =
  "fz-jn81hQoCNcFinQ80_vV:APA91bGZ-6bS4na3cFDo201QW9Kkqha7VeHP8q-mkCwgqjhJv-yteIEnmYEyfdewnsi9eqx85weotQ2ZbDc_yKKV2iMHPEcDIhDbczzmftGCsY69lX6JCCR_a8_T_GGt67X8c2WG0yg0";
describe("Send push notification test", () => {
  // it("send message to topic", async () => {
  //   const testTopic = "sendingToTestTopic";

  //   await Messaging.subscribeToTopic(validToken1, testTopic);
  //   const re = await Messaging.sendMessageToTopic({
  //     topic: testTopic,
  //     title: "push title test via topic 1",
  //     body: "push body test via topic 1",
  //   });
  //   expect(re!.result != null);
  //   expect(re!.result).include("projects/");
  // });

  // it("send message to token", async () => {
  //   let re = await Messaging.sendMessageToTokens({
  //     tokens: "invalidToken-this-is-not-valid",
  //     title: "push title test via token 1",
  //     body: "push body test via token 1",
  //   });
  //   expect(re.code).equal("success");
  //   expect(re.result!.error).equal(1);

  //   re = await Messaging.sendMessageToTokens({
  //     tokens: validToken1,
  //     title: "push title test via token 1",
  //     body: "push body test via token 1",
  //   });
  //   expect(re.code).equal("success");
  //   expect(re.result!.success).equal(1);

  //   re = await Messaging.sendMessageToTokens({
  //     tokens: validToken1 + "," + validToken2 + "," + "invalidtoken",
  //     title: "push title test via multiple tokens as string",
  //     body: "push body test via multiple tokens  as string",
  //   });
  //   expect(re.code).equal("success");
  //   expect(re!.result!.success).equal(2);
  //   expect(re!.result!.error).equal(1);
  // });

  it("send message to user", async () => {
    const userA = "sendMessaegUserA" + Utils.getTimestamp();
    const userB = "sendMessaegUserB" + Utils.getTimestamp();
    await Test.createTestUser(userA);
    await Test.createTestUser(userB);

    const tokenUpdates = [];
    tokenUpdates.push(Ref.messageTokens.child(validToken1).set({ uid: userA }));
    tokenUpdates.push(Ref.messageTokens.child(validToken2).set({ uid: userB }));
    await Promise.all(tokenUpdates);

    let re = await Messaging.sendMessageToUsers({
      uids: userA,
      title: "push title 1",
      body: "push body 1",
    });
    expect(re.code).equal("success");

    re = await Messaging.sendMessageToUsers({
      uids: userA + "," + userB,
      title: "push title 1",
      body: "push body 1",
    });
    expect(re.code).equal("success");
    expect(re.result!.success).equal(2);

    re = await Messaging.sendMessageToUsers({
      uids: userA + "," + userB + "," + "abcd",
      title: "push title 1",
      body: "push body 1",
    });
    expect(re.code).equal("success");
    expect(re.result!.success).equal(2);
    expect(re.result!.error).equal(0);
  });
});
