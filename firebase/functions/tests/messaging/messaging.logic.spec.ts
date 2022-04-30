import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Messaging } from "../../src/classes/messaging";

new FirebaseAppInitializer();

describe("Messaging logic test", () => {
  it("Set token", async () => {
    await Messaging.setToken({ uid: "a", token: "t" });
    const doc = await Messaging.getToken("t");
    console.log("doc;", doc);
    expect(doc).to.be.an("object").to.have.property("token").equal("t");
  });
  it("unsubscribeAllTopicOfToken", async () => {
    console.log("@fix empty");
  });
  it("resubscribeAllUserTopics", async () => {
    console.log("@fix empty");
  });
});
