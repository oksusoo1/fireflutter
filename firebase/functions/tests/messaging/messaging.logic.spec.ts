import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Messaging } from "../../src/classes/messaging";

new FirebaseAppInitializer();

describe("Messaging logic test", () => {
  // it("Set token", async () => {
  //   await Messaging.setToken({ uid: "a", token: "t" });
  //   const doc = await Messaging.getToken("t");
  //   console.log("doc;", doc);
  //   expect(doc).to.be.an("object").to.have.property("token").equal("t");
  // });
  it("unsubscribeAllTopicOfToken", async () => {
    const res = await Messaging.unsubscribeAllTopicOfToken("fakeToken1");
    expect(res.length).to.be.equal(0);
    const validToken =
      "eTb93wtfj0z4vsZEvEoPQ4:APA91bHBz3msWxf4VvaBXeRxgpord3JWaiDAkioKxQF-WxrT4FCXuzzDVlV8dXXWFefm3ANFzAti0ciYgkJDyRAXc-5Oj7T_kZXNJ5E5DockQ831RJadTtHkB54vlHey3rWijbOR_FZr";
    Messaging.subscribeToTopic(validToken, "sampleTopic");
    const tokenRes = await Messaging.unsubscribeAllTopicOfToken(validToken);
    expect(tokenRes.length).equal(1);
    const noTopicRes = await Messaging.unsubscribeAllTopicOfToken(validToken);
    expect(noTopicRes.length).equal(0);
  });
  // it("resubscribeAllUserTopics", async () => {});
});
