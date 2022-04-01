import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Post } from "../../src/classes/post";
import { ERROR_EMPTY_CATEGORY, ERROR_EMPTY_UID } from "../../src/defines";

new FirebaseAppInitializer();

describe("Post create test", () => {
  it("Succed to create a post", async () => {
    const post = await Post.create({ uid: "a", category: "cat1", title: "yo", a: "apple" } as any);
    expect(post).not.to.be.null;
    expect(post!.category === "cat1").true;
  });
  it("Fail - ERROR_EMPTY_UID", async () => {
    try {
      await Post.create({ category: "cat1", title: "yo" } as any);
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_UID);
    }
  });
  it("Fail - ERROR_EMPTY_CATEGORY", async () => {
    try {
      await Post.create({ uid: "cat1", title: "yo" } as any);
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_CATEGORY);
    }
  });
});
