import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Post } from "../../src/classes/post";
import {
  ERROR_CATEGORY_NOT_EXISTS,
  ERROR_EMPTY_CATEGORY,
  ERROR_EMPTY_UID,
} from "../../src/defines";

import { Test } from "../../src/classes/test";

new FirebaseAppInitializer();

describe("Post create test", () => {
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

  it("Fail - ERROR_CATEGORY_NOT_EXISTS", async () => {
    try {
      await Post.create({ uid: "cat1", category: "not-exists" } as any);
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_CATEGORY_NOT_EXISTS);
    }
  });

  it("Succed to create a post", async () => {
    const category = await Test.createCategory();

    const post = await Post.create({
      uid: "a",
      password: "abc",
      category: category.id,
      title: "yo",
      a: "apple",
    } as any);
    // console.log(post);
    expect(post).not.to.be.null;
    expect(post!.category === category.id).true;
    expect(post!.a === "apple").true;
  });
});
