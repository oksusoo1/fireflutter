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
import { PostDocument } from "../../src/interfaces/forum.interface";

new FirebaseAppInitializer();

let totalPosts: Array<PostDocument> = [];

describe("Post list test", () => {
  it("Create some posts for test", async () => {
    // create 31 posts.
    const category = await Test.createCategory();
    const promises = [];
    for (let i = 1; i <= 31; i++) {
      promises.push(
        Post.create({
          uid: "test-uid",
          category: category.id,
          title: "test-title-" + i,
        } as any)
      );
    }
    await Promise.all(promises);
  });

  it("Get first page.", async () => {
    totalPosts = await Post.list({ category: undefined, limit: undefined, startAfter: undefined });
    for (let i = 1; i <= 10; i++) {
      expect(totalPosts[i - 1])
        .to.be.an("object")
        .to.have.property("title")
        .equals("test-title-" + i);
    }
  });

  it("Get second page.", async () => {
    const posts = await Post.list({
      category: undefined,
      limit: undefined,
      startAfter: totalPosts[totalPosts.length - 1].createdAt,
    });
    for (let i = 1; i <= 10; i++) {
      expect(posts[i - 1])
        .to.be.an("object")
        .to.have.property("title")
        .equals("test-title-" + i);
    }
    totalPosts = [...totalPosts, ...posts];
  });

  it("Get third page.", async () => {
    const posts = await Post.list({ category: undefined, limit: undefined, startAfter: undefined });
    for (let i = 1; i <= 10; i++) {
      expect(posts[i - 1])
        .to.be.an("object")
        .to.have.property("title")
        .equals("test-title-" + i);
    }
    totalPosts = [...totalPosts, ...posts];
  });

  it("Get forth page.", async () => {
    const posts = await Post.list({ category: undefined, limit: undefined, startAfter: undefined });
    for (let i = 1; i <= 10; i++) {
      expect(posts[i - 1])
        .to.be.an("object")
        .to.have.property("title")
        .equals("test-title-" + i);
    }
    totalPosts = [...totalPosts, ...posts];
  });
});
