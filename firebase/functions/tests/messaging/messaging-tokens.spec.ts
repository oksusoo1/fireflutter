import "mocha";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Test } from "../../src/classes/test";
import { Utils } from "../../src/classes/utils";

import { Messaging } from "../../src/classes/messaging";
import { expect } from "chai";

new FirebaseAppInitializer();

describe("Tokens test", () => {
  it("Token saving test for one user", async () => {
    // Create two users
    const a = "A-" + Utils.getTimestamp();
    await Test.createTestUserAndGetDoc(a);

    await Messaging.updateToken(a, "fake-token-2");
    await Messaging.updateToken(a, "fake-token-1");
    const tokens = await Messaging.getTokens(a);
    expect(tokens).to.be.an("array");
    expect(tokens).to.be.an("array").contains("fake-token-1");
    expect(tokens).to.be.an("array").contains("fake-token-2");
  });
  it("Token saving test for two user", async () => {
    // Create two users
    const a = "a2-" + Utils.getTimestamp();
    const b = "b2-" + Utils.getTimestamp();
    await Test.createTestUser(a);
    await Test.createTestUser(b);

    // Add 4 tokens
    const promises = [];
    promises.push(Messaging.updateToken(a, "fake-token-a-1"));
    promises.push(Messaging.updateToken(a, "fake-token-a-2"));
    promises.push(Messaging.updateToken(b, "fake-token-b-3"));
    promises.push(Messaging.updateToken(b, "fake-token-b-4"));
    await Promise.all(promises);

    const tokens = await Messaging.getTokensFromUids([a, b].join(","));

    expect(tokens).to.be.an("array").length(4);

    expect(tokens).to.be.an("array").contains("fake-token-a-1");
    expect(tokens).to.be.an("array").contains("fake-token-a-2");
    expect(tokens).to.be.an("array").contains("fake-token-b-3");
    expect(tokens).to.be.an("array").contains("fake-token-b-4");
  });
  it("Token get for user with no token", async () => {
    // Create a user
    const a = "A3-" + Utils.getTimestamp();
    await Test.createTestUserAndGetDoc(a);

    const tokens = await Messaging.getTokens(a);
    expect(tokens).to.be.an("array");
    expect(tokens).empty;
  });
});
