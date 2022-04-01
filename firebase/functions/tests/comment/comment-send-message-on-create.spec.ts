import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Post } from "../../src/classes/post";
import { PostDocument } from "../../src/interfaces/forum.interface";
import { Utils } from "../../src/classes/utils";

new FirebaseAppInitializer();

describe("Send message on comment create test", () => {
  it("Sende Message on comment create", async () => {
    const commentId = "commentTest" + Utils.getTimestamp();
  });
});
