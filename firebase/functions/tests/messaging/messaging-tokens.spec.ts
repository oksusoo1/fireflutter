import "mocha";
// import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Test } from "../../src/library/test";
// import { Ref } from "../../src/library/ref";

// import { PushMessaging } from "../../src/library/push-messaging";

new FirebaseAppInitializer();

describe("get tokens test", () => {
  it("retrieve push tokens test", async () => {
    const userA = "retrieveTokenUserA";
    // const userB = "retrieveTokenUserB";
    try {
      await Test.createTestUser(userA);
    } catch (e) {
      console.log(e);
    }

    // await Test.createTestUser(userB);

    // const tokenUpdates = [];
    // tokenUpdates.push(
    //   Ref.messageTokens.child("fakeToken1").set({ uid: userA })
    // );
    // tokenUpdates.push(
    //   Ref.messageTokens.child("fakeToken2").set({ uid: userA })
    // );
    // tokenUpdates.push(
    //   Ref.messageTokens.child("fakeToken3").set({ uid: userA })
    // );
    // tokenUpdates.push(
    //   Ref.messageTokens.child("fakeToken4").set({ uid: userB })
    // );
    // await Promise.all(tokenUpdates);

    // const res1 = await PushMessaging.getTokensFromUids(userA);
    // expect(res1.length).equal(3, "mush have 3 token");

    // const res2 = await PushMessaging.getTokensFromUids(userA + "," + userB);
    // expect(res2.length).equal(4, "A and B must have 4 tokens in total");

    // const res3 = await PushMessaging.getTokensFromUids([userB, userB]);
    // expect(res3.length).equal(1, "B and B must 1 token");

    // create user

    // update user tokens

    // check user tokens

    // topicsubscriber

    // chatsubscriber
  });
});
