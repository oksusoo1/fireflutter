import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Messaging } from "../../src/classes/messaging";
import { Test } from "../../src/classes/test";
import { Utils } from "../../src/classes/utils";
import { MessagingTopicManagementResponse } from "firebase-admin/lib/messaging/messaging-api";
import { ERROR_EMPTY_TOPIC, ERROR_EMPTY_TOPIC_TYPE, ERROR_EMPTY_TOKEN, ERROR_EMPTY_UID } from "../../src/defines";

new FirebaseAppInitializer();

const validToken =
  "c8D2PLZnQN2Vi37Jev-862:APA91bFPos97KyVDjALGNhqYrnt469J2C6PvHWQtQi6HcWWKVSUzFag01PtU0cMLYFcDWge4CScYJLdcF1Y7KW4VHZ44GcGzGayNGO3NrJd7NUwC9DbfSI2jngoCKpS7nwNpm9VBoKmy";
const validToken1 =
  "fiXLW5_MlUUSrJPvyJVVAh:APA91bG4g4PD8qoX6Jp5EbkBNq_amthvmfXAqT1sAX2v8qKfBkTtmWLicKj-Y-Rp7X1tNRA3bk_kfK_f-YDztk8PTHgln0ydwcJC7fjeicDOaGesE8dH-Xxoa5bh2iOa_qqkRChv7ZpZ";

describe("Messaging logic test", () => {
  it("Set token", async () => {
    try {
      await Messaging.setToken({
        uid: "",
        token: "",
      });
      const re1 = await Messaging.getToken("t");
      expect.fail("must throw ERROR_EMPTY_UID" + re1);
    } catch (e) {
      expect(e).to.be.equal(ERROR_EMPTY_UID);
    }
    try {
      await Messaging.setToken({
        uid: "abc",
        token: "",
      });
      const re2 = await Messaging.getToken("t");
      expect.fail("must throw ERROR_EMPTY_TOKEN" + re2);
    } catch (e) {
      expect(e).to.be.equal(ERROR_EMPTY_TOKEN);
    }
    await Messaging.setToken({ uid: "a", token: "t" });
    const doc = await Messaging.getToken("t");
    expect(doc).to.be.an("object").to.have.property("token").equal("t");
  });
  it("checkTopicData", async () => {
    const data = {
      test1: null,
      test2: undefined,
      test3: "",
    };
    expect(!data.test1).to.be.true;
    expect(!data.test2).to.be.true;
    expect(!data.test3).to.be.true;
    const data2: any = {};
    expect(!data2.test4).to.be.true;
    try {
      Messaging.checkTopicData({
        uid: "",
        topic: "",
        type: "",
      });
      expect.fail("must throw ERROR_EMPTY_UID");
    } catch (e) {
      expect(e).to.be.equal(ERROR_EMPTY_UID);
    }
    try {
      Messaging.checkTopicData({
        uid: "a",
        topic: "",
        type: "",
      });
      expect.fail("must throw ERROR_EMPTY_TOPIC");
    } catch (e) {
      expect(e).to.be.equal(ERROR_EMPTY_TOPIC);
    }
    try {
      Messaging.checkTopicData({
        uid: "a",
        topic: "b",
        type: "",
      });
      expect.fail("must throw ERROR_EMPTY_TOPIC_TYPE");
    } catch (e) {
      expect(e).to.be.equal(ERROR_EMPTY_TOPIC_TYPE);
    }
    try {
      Messaging.checkTopicData({
        uid: "a",
        topic: "b",
        type: "c",
      });
      expect(true, "must not throw any");
    } catch (e) {
      expect.fail("must throw ERROR_EMPTY_TOPIC_TYPE");
    }
  });
  it("remove invalid tokens", async () => {
    const A = "removeinvalidToken-" + Utils.getTimestamp();
    await Test.createTestUserAndGetDoc(A);
    await Messaging.setToken({ uid: A, token: "fake-token-abc" });
    await Messaging.removeInvalidTokens(A);
    let tokens = await Messaging.getTokens(A);
    expect(tokens.length).to.be.equal(0);
    await Messaging.setToken({ uid: A, token: validToken });
    await Messaging.setToken({ uid: A, token: "fake-token-efg" });
    await Messaging.removeInvalidTokens(A);
    tokens = await Messaging.getTokens(A);
    expect(tokens).include(validToken);
  });
  it("unsubscribeAllTopicOfToken", async () => {
    const A1 = "unsubscribeAllTopicOfToken-" + Utils.getTimestamp();
    await Test.createTestUserAndGetDoc(A1);
    const res1 = await Messaging.unsubscribeAllTopicOfToken("fakeToken1");
    expect(res1.length).to.be.equal(0);
    await Messaging.setToken({ uid: A1, token: validToken });
    await Messaging.subscribeToTopic({ uid: A1, topic: "fake-topic-unsubs", type: "forum" });
    const tokenRes = await Messaging.unsubscribeAllTopicOfToken(validToken);
    expect(tokenRes.length).greaterThanOrEqual(1);
    const noTopicRes = await Messaging.unsubscribeAllTopicOfToken(validToken);
    expect(noTopicRes.length).equal(0);
  });
  it("resubscribeAllUserTopics", async () => {
    const A2 = "resubscribeAllUserTopics-" + Utils.getTimestamp();
    await Test.createTestUserAndGetDoc(A2);
    await Messaging.setToken({ uid: A2, token: validToken });
    await Messaging.setToken({ uid: A2, token: validToken1 });
    await Messaging.setToken({ uid: A2, token: "invalid-token-098" });
    await Messaging.setToken({ uid: A2, token: "invalid-token-qwe" });
    const re = await Messaging.subscribeToTopic({ uid: A2, topic: "fake-topic-abc", type: "forum" });
    expect(re.successCount).equal(2);
    expect(re.failureCount).equal(2);
    expect(re.failureTokens["invalid-token-098"]).equal("messaging/invalid-registration-token");
    expect(Object.keys(re.failureTokens)).includes("invalid-token-qwe");
    await Messaging.subscribeToTopic({ uid: A2, topic: "fake-topic-123", type: "forum" });
    const re2 = await Messaging.subscribeToTopic({ uid: A2, topic: "fake-topic-zxc", type: "forum" });
    expect(re2.failureCount).equal(0);
    const res = await Messaging.resubscribeAllUserTopics(A2);
    expect(res).to.be.an("object");
    expect(res.forum).to.be.an("array");
    expect(res.forum!.length).equal(3);
    expect(res.forum![0].tokens!.length).equal(2);
    expect(res.forum![0].topic).oneOf(["fake-topic-123", "fake-topic-abc", "fake-topic-zxc"]);
  });
  it("remove invalid tokens", async () => {
    const tokenA = "invalideTOkenA";
    const tokenB = "invalideTOkenB";
    await Messaging.setToken({ uid: "removeInvalidTokenUser", token: tokenA });
    await Messaging.setToken({ uid: "removeInvalidTokenUser", token: tokenB });
    const tokens = await Messaging.getTokens("removeInvalidTokenUser");
    expect(tokens.length).equal(2);
    const reponse = {
      successCount: 0,
      failureCount: 2,
      errors: [
        {
          index: 0,
          error: {
            code: "messaging/invalid-registration-token",
            message: "abc",
          },
        },
        {
          index: 1,
          error: {
            code: "messaging/invalid-registration-token",
            message: "123",
          },
        },
      ],
    } as MessagingTopicManagementResponse;
    const res = await Messaging.removeInvalidTokensFromResponse([tokenA, tokenB], reponse);
    expect(res).to.be.an("object");
    const tokens2 = await Messaging.getTokens("removeInvalidTokenUser");
    expect(tokens2.length).equal(0);
  });
  it("topics turnOn", async () => {
    const T1 = "TopicOnUser-" + Utils.getTimestamp();
    const data = { uid: T1, type: "chat", topic: "chat_userAbc" };
    await Messaging.topicOn(data);
    let res = await Messaging.getTopic(data);
    expect(res).to.be.an("object");
    expect(res![data.topic]).to.be.true;
    await Messaging.topicOff(data);
    res = await Messaging.getTopic(data);
    expect(res![data.topic]).to.be.false;
    await Messaging.topicToggle(data);
    res = await Messaging.getTopic(data);
    expect(res![data.topic]).to.be.true;
    await Messaging.topicToggle(data);
    res = await Messaging.getTopic(data);
    expect(res![data.topic]).to.be.false;
  });
});
