import "mocha";

import { FirebaseAppInitializer } from "../firebase-app-initializer";

import { Messaging } from "../../src/classes/messaging";
import { expect } from "chai";
import {
  ERROR_EMPTY_TOKENS,
  ERROR_EMPTY_UIDS,
  ERROR_EMPTY_TOPIC,
  ERROR_TITLE_AND_BODY_CANT_BE_BOTH_EMPTY,
} from "../../src/defines";

import { Test } from "../../src/classes/test";
import { Ref } from "../../src/classes/ref";
import { Utils } from "../../src/classes/utils";

new FirebaseAppInitializer();

const testTopic = "sendingToTestTopic";

const validToken1 =
  "dT9S0cPbQ3OSRCbB8EG9li:APA91bHKVGQneklgn1baHTlE4xufYSdNrqt59JB4vRTxPYYjoGyiHhFkxBhYyE2sG6DFOCZ7oWEmne9GLKQje5YYCsLWIevg6W7kLQYl9gDERH6-s1Q_1C5vn5XCZf1mhdBr_KYPVKvX";
const validToken2 =
  "fz-jn81hQoCNcFinQ80_vV:APA91bGZ-6bS4na3cFDo201QW9Kkqha7VeHP8q-mkCwgqjhJv-yteIEnmYEyfdewnsi9eqx85weotQ2ZbDc_yKKV2iMHPEcDIhDbczzmftGCsY69lX6JCCR_a8_T_GGt67X8c2WG0yg0";
describe("Send push notification test", () => {
  it("ERROR_EMPTY_TOPIC", async () => {
    try {
      await Messaging.sendMessageToTopic({
        title: "push title test via topic 1",
        body: "push body test via topic 1",
      });
      expect.fail("must be error of ERROR_EMPTY_TOPIC");
    } catch (e) {
      expect(e).equal(ERROR_EMPTY_TOPIC);
    }
  });
  it("ERROR_TITLE_AND_BODY_CANT_BE_BOTH_EMPTY", async () => {
    try {
      await Messaging.sendMessageToTopic({
        topic: testTopic,
      });
      expect.fail("must be error of ERROR_TITLE_AND_BODY_CANT_BE_BOTH_EMPTY");
    } catch (e) {
      expect(e).equal(ERROR_TITLE_AND_BODY_CANT_BE_BOTH_EMPTY);
    }
  });
  it("messageId: 'projects/{project-name}/messages/XXXXXXXXXXXX", async () => {
    const testTopic = "sendingToTestTopic";
    const re = await Messaging.sendMessageToTopic({
      topic: testTopic,
      title: "push title test via topic 1",
      body: "push body test via topic 1",
    });
    expect(re.messageId != null);
    expect(re.messageId).include("projects/");
  });

  it("ERROR_EMPTY_TOKENS", async () => {
    try {
      await Messaging.sendMessageToTokens({});
      expect.fail("must fail error empty tokens");
    } catch (e) {
      expect(e).equal(ERROR_EMPTY_TOKENS);
    }
  });

  it("ERROR_TITLE_AND_BODY_CANT_BE_BOTH_EMPTY", async () => {
    try {
      await Messaging.sendMessageToTokens({
        tokens: "invalidToken-this-is-not-valid",
      });
      expect.fail("must fail error empty tokens");
    } catch (e) {
      expect(e).equal(ERROR_TITLE_AND_BODY_CANT_BE_BOTH_EMPTY);
    }
  });

  it("invalidToken-this-is-not-validi", async () => {
    try {
      const re = (await Messaging.sendMessageToTokens({
        tokens: "invalidToken-this-is-not-valid",
        title: "push title test via token 1",
        body: "push body test via token 1",
      })) as { success: number; error: number };
      expect(re.success).equal(0);
      expect(re.error).equal(1);
    } catch (e) {
      expect.fail("no throw error");
    }
  });

  it("validToken1", async () => {
    try {
      const re = (await Messaging.sendMessageToTokens({
        tokens: validToken1,
        title: "push title test via token 1",
        body: "push body test via token 1",
      })) as { success: number; error: number };
      expect(re.error).equal(0);
      expect(re.success).equal(1);
    } catch (e) {
      expect.fail("no throw error");
    }
  });

  it("validToken1,validToken2,invalidtoken", async () => {
    try {
      const re = (await Messaging.sendMessageToTokens({
        tokens: validToken1 + "," + validToken2 + "," + "invalidtoken",
        title: "push title test via token 1",
        body: "push body test via token 1",
      })) as { success: number; error: number };
      expect(re.error).equal(1);
      expect(re.success).equal(2);
    } catch (e) {
      expect.fail("no throw error");
    }
  });

  it("ERROR_EMPTY_UIDS", async () => {
    try {
      await Messaging.sendMessageToUsers({});
      expect.fail("empty uids");
    } catch (e) {
      expect(e).equal(ERROR_EMPTY_UIDS);
    }
  });

  it("ERROR_TITLE_AND_BODY_CANT_BE_BOTH_EMPTY", async () => {
    try {
      await Messaging.sendMessageToUsers({
        uids: "fakeuser",
      });
      expect.fail("empty uids");
    } catch (e) {
      expect(e).equal(ERROR_TITLE_AND_BODY_CANT_BE_BOTH_EMPTY);
    }
  });

  it("fakeuser", async () => {
    try {
      const re = (await Messaging.sendMessageToUsers({
        uids: "fakeuser",
        title: "push title 1",
        body: "push body 1",
      })) as { success: number; error: number };
      expect(re.error).equal(0);
      expect(re.success).equal(0);
    } catch (e) {
      expect.fail("fakeuser");
    }
  });

  it("validUser", async () => {
    const userA = "sendMessaegUserA" + Utils.getTimestamp();
    const userB = "sendMessaegUserB" + Utils.getTimestamp();
    await Test.createTestUser(userA);
    await Test.createTestUser(userB);

    const tokenUpdates = [];
    tokenUpdates.push(Ref.messageTokens.child(validToken1).set({ uid: userA }));
    tokenUpdates.push(Ref.messageTokens.child(validToken2).set({ uid: userB }));
    await Promise.all(tokenUpdates);
    try {
      const re = (await Messaging.sendMessageToUsers({
        uids: userA,
        title: "push title 1",
        body: "push body 1",
      })) as { success: number; error: number };
      expect(re.error).equal(0);
      expect(re.success).equal(1);
    } catch (e) {
      expect.fail("validUser1");
    }

    try {
      const re = (await Messaging.sendMessageToUsers({
        uids: userA + "," + userB,
        title: "push title 1",
        body: "push body 1",
      })) as { success: number; error: number };
      expect(re.error).equal(0);
      expect(re.success).equal(2);
    } catch (e) {
      expect.fail("validUser2");
    }

    try {
      const re = (await Messaging.sendMessageToUsers({
        uids: userA + "," + userB + "," + "abcd",
        title: "push title 1",
        body: "push body 1",
      })) as { success: number; error: number };
      expect(re.error).equal(0);
      expect(re.success).equal(2);
    } catch (e) {
      expect.fail("validUser2");
    }
  });
});
