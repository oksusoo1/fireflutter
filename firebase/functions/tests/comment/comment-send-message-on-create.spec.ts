import "mocha";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Utils } from "../../src/classes/utils";

new FirebaseAppInitializer();

describe("Send message on comment create test", () => {
  it("Sende Message on comment create", async () => {
    const commentId = "commentTest" + Utils.getTimestamp();
  });
});
