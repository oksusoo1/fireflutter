/**
 * - input test
 * - wrong id test
 * - wrong uid test
 * - empty files and put some files, and see if `hasPhoto` changes.
 * - updatedAt change test
 */
import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Post } from "../../src/classes/post";
import { ERROR_EMPTY_CATEGORY, ERROR_EMPTY_UID } from "../../src/defines";
import { PostDocument } from "../../src/interfaces/forum.interface";
import { Utils } from "../../src/classes/utils";
import { User } from "../../src/classes/user";

new FirebaseAppInitializer();

let post: PostDocument;
let uid = "test-user-" + Utils.getTimestamp();

describe("Post update test", () => {
  it("Prepare a post (by creating a user)", async () => {
    await User.create(uid, {
      firstName: "fn",
    });
    const user = await User.get(uid);

    post = await Post.create({
      uid: user.id,
      password: "abc",
      category: "cat1",
      title: "yo",
      a: "apple",
    } as any);
    // console.log(post);
    expect(post).not.to.be.null;
    expect(post!.category === "cat1").true;
    expect(post!.a === "apple").true;
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
