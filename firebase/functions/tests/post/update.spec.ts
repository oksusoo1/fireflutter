/**
 * - input test
 * - wrong id test
 * - wrong uid test and correct uid
 * - update title, content and extra data.
 * - empty files and put some files, and see if `hasPhoto` changes.
 * - updatedAt change test
 */
import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Post } from "../../src/classes/post";
import { PostDocument } from "../../src/interfaces/forum.interface";
import { Utils } from "../../src/classes/utils";
import { User } from "../../src/classes/user";
import { ERROR_EMPTY_ID, ERROR_NOT_YOUR_POST, ERROR_POST_NOT_EXIST } from "../../src/defines";

new FirebaseAppInitializer();

let post: PostDocument;
const uid = "test-user-" + Utils.getTimestamp();

describe("Post update test", () => {
  it("Prepare a post for updating (by creating a user)", async () => {
    await User.create(uid, {
      firstName: "fn",
    });
    const user = await User.get(uid);

    post = await Post.create({
      uid: user.id,
      category: "cat1",
      title: "title",
      a: "apple",
    } as any);

    expect(post).not.to.be.null;
    expect(post!.category === "cat1").true;
    expect(post!.title === "title").true;
    expect(post!.a === "apple").true;
  });
  it("Input test with empty object", async () => {
    try {
      await Post.update({});
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_ID);
    }
  });
  it("Input test with wrong id", async () => {
    try {
      await Post.update({ id: "abc" });
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_POST_NOT_EXIST);
    }
  });
  it("Input test with wrong id", async () => {
    try {
      await Post.update({ id: post.id });
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_NOT_YOUR_POST);
    }
  });
});
