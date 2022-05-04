import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Messaging } from "../../src/classes/messaging";
import { Test } from "../../src/classes/test";
import { Utils } from "../../src/classes/utils";

new FirebaseAppInitializer();

const validToken =
  "c8D2PLZnQN2Vi37Jev-862:APA91bFPos97KyVDjALGNhqYrnt469J2C6PvHWQtQi6HcWWKVSUzFag01PtU0cMLYFcDWge4CScYJLdcF1Y7KW4VHZ44GcGzGayNGO3NrJd7NUwC9DbfSI2jngoCKpS7nwNpm9VBoKmy";

describe("Messaging logic test", () => {
  it("Set token", async () => {
    await Messaging.setToken({ uid: "a", token: "t" });
    const doc = await Messaging.getToken("t");
    expect(doc).to.be.an("object").to.have.property("token").equal("t");
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
    const A = "unsubscribeAllTopicOfToken-" + Utils.getTimestamp();
    await Test.createTestUserAndGetDoc(A);
    const res = await Messaging.unsubscribeAllTopicOfToken("fakeToken1");
    expect(res.length).to.be.equal(0);
    await Messaging.setToken({ uid: A, token: validToken });
    await Messaging.subscribeToTopic({ uid: A, topic: "fake-topic-unsubs", type: "forum" });
    const tokenRes = await Messaging.unsubscribeAllTopicOfToken(validToken);
    // console.log(tokenRes);
    expect(tokenRes.length).equal(1);
    const noTopicRes = await Messaging.unsubscribeAllTopicOfToken(validToken);
    expect(noTopicRes.length).equal(0);
  });
  it("resubscribeAllUserTopics", async () => {
    const A = "resubscribeAllUserTopics-" + Utils.getTimestamp();
    await Test.createTestUserAndGetDoc(A);
    await Messaging.setToken({ uid: A, token: validToken });
    await Messaging.setToken({ uid: A, token: "invalid-token-123" });
    await Messaging.subscribeToTopic({ uid: A, topic: "fake-topic-abc", type: "forum" });
    // const res = await Messaging.resubscribeAllUserTopics(A);
    // console.log(res);
  });
});
