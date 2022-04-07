import "mocha";

import { FirebaseAppInitializer } from "../firebase-app-initializer";

import { Messaging } from "../../src/classes/messaging";
// import { expect } from "chai";
// import {
//   ERROR_EMPTY_TOKENS,
//   ERROR_EMPTY_UIDS,
//   ERROR_EMPTY_TOPIC,
//   ERROR_TITLE_AND_BODY_CANT_BE_BOTH_EMPTY,
// } from "../../src/defines";

// import { Test } from "../../src/classes/test";
// import { Ref } from "../../src/classes/ref";
// import { Utils } from "../../src/classes/utils";

new FirebaseAppInitializer();

describe("Test Mock data", () => {
  //   it("getTokensFromUids", async () => {
  //     try {
  //       const tokens = await Messaging.getTokensFromUids("wWyLWVufzYObiZeNIYCOQy4fQw02");
  //       console.log(tokens);
  //     } catch (e) {
  //       console.log(e);
  //     }
  //   });

  it("chat message mock data", async () => {
    try {
      const re = await Messaging.sendMessageToUsers({
        title: "Selrahc sent a message",
        content: "sendMessageToUsers",
        uids: "wWyLWVufzYObiZeNIYCOQy4fQw02",
        badge: "16",
        subscription: "chatNotifyMXhctaDjbtMKyWJO3C3fHA7sMnn1",
        type: "chat",
        senderUid: "MXhctaDjbtMKyWJO3C3fHA7sMnn1",
      });
      console.log(re);
    } catch (e) {
      console.log(e);
    }
  });
});
