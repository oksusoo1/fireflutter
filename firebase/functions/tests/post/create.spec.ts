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
import { Utils } from "../../src/classes/utils";

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
    expect(post).not.to.be.null;
    expect(post!.category === category.id).true;
    expect(post!.a === "apple").true;
  });

  it("Giving document id to be created with", async () => {
    const category = await Test.createCategory();
    const documentId = "d-id-" + Utils.getTimestamp();

    const post = await Post.create({
      uid: "a",
      password: "abc",
      category: category.id,
      documentId: documentId,
      title: "yo",
      a: "apple",
    } as any);

    expect(post).not.to.be.null;
    expect(post.category === category.id).true;
    expect(post.a === "apple").true;

    expect(post.id).equals(documentId);
  });

  it("Files test - undefined", async () => {
    const category = await Test.createCategory();
    const post = await Post.create({
      uid: "a",
      category: category.id,
    });
    expect(post.files).to.be.an("array");
    expect(post.hasPhoto).to.be.false;
  });
  it("Files test - empty array", async () => {
    const category = await Test.createCategory();
    const post = await Post.create({
      uid: "a",
      category: category.id,
      files: [],
    });
    expect(post.files).to.be.an("array");
    expect(post.hasPhoto).to.be.false;
  });
  it("Files test - two photos", async () => {
    const category = await Test.createCategory();
    const post = await Post.create({
      uid: "a",
      category: category.id,
      files: ["a", "b"],
    });
    expect(post.files).to.be.an("array");
    expect(post.hasPhoto).to.be.true;
    expect(post).to.be.an("object").to.have.property("files").to.be.an("array").lengthOf(2);
    expect(post.files![0]).equals("a");
    expect(post.files![1]).equals("b");
  });
});
