/**
 * - input test
 * - wrong id test (post does not exits)
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
    if (user === null) expect.fail();

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
  it("Input test with wrong id (post does not exists)", async () => {
    try {
      await Post.update({ id: "abc" });
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_POST_NOT_EXIST);
    }
  });
  it("Input test with wrong uid (not my post)", async () => {
    try {
      await Post.update({ id: post.id });
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_NOT_YOUR_POST);
    }
  });
  it("Input test with correct uid", async () => {
    const res = await Post.update({ id: post.id, uid: post.uid });
    expect(res).to.be.not.null;
    expect(res.id).to.be.not.null;
  });
  it("Input test update data (title, content, noOfComments)", async () => {
    // title
    const title = "post test title - " + Utils.getTimestamp();
    const titleUpdate = await Post.update({ id: post.id, uid: post.uid, title });
    expect(titleUpdate.title).to.be.equals(title);

    // content
    const content = "post test content - " + Utils.getTimestamp();
    const contentUpdate = await Post.update({ id: post.id, uid: post.uid, content });
    expect(contentUpdate.content).to.be.equals(content);

    // number of comments
    const noOfCommentsUpdate = await Post.update({ id: post.id, uid: post.uid, noOfComments: 5 });
    expect(noOfCommentsUpdate.noOfComments).to.be.equals(5);
  });
  it("Input test update files to affect hasPhoto", async () => {
    let hasPhotoUpdate = await Post.update({ id: post.id, uid: post.uid, files: ["test"] });
    expect(hasPhotoUpdate!.hasPhoto).to.be.equals(true);

    hasPhotoUpdate = await Post.update({ id: post.id, uid: post.uid, files: [] });
    expect(hasPhotoUpdate!.hasPhoto).to.be.equals(false);
  });

  it("Input test updateAt changes", async () => {
    const updateA = await Post.update({ id: post.id, uid: post.uid, like: 2 });
    expect(updateA.like).to.be.not.equals(post.like);
    expect(updateA.updatedAt).to.be.not.equals(post.updatedAt);

    await Utils.delay(1100);

    const updateB = await Post.update({ id: post.id, uid: post.uid, like: 3 });
    expect(updateB.like).to.be.greaterThan(updateA.like);
    expect(updateB.updatedAt).to.be.not.equals(updateA.updatedAt);

    expect((updateB.updatedAt! as any)["_seconds"]).to.be.greaterThan(
        (updateA.updatedAt! as any)["_seconds"]
    );
  });
});
