import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Post } from "../../src/classes/post";
import { PostDocument } from "../../src/interfaces/forum.interface";
import { Utils } from "../../src/classes/utils";
import { User } from "../../src/classes/user";
import {
  ERROR_ALREADY_DELETED,
  ERROR_EMPTY_ID,
  ERROR_NOT_YOUR_POST,
  ERROR_POST_NOT_EXIST,
} from "../../src/defines";
import { Storage } from "../../src/classes/storage";

new FirebaseAppInitializer();

let post: PostDocument;
const uid = "test-user-" + Utils.getTimestamp();

describe("Post delete test", () => {
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
      noOfComments: 1,
    } as any);

    expect(post).not.to.be.null;
    expect(post!.category === "cat1").true;
    expect(post!.title === "title").true;
    expect(post!.a === "apple").true;
  });

  /**
   * - input test
   *  - no id (error empty id)
   *  - wrong id test (post does not exits)
   *  - empty uid test (not your post)
   *  - wrong uid test (not your post)
   *  - correct uid (success delete, marked as deleted)
   *  - already deleted (already deleted)
   *  - success (completely deleted)
   */
  it("Input test no post ID", async () => {
    try {
      await Post.delete({ id: "", uid: "" });
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_ID);
    }
  });
  it("Input test wrong post ID", async () => {
    try {
      await Post.delete({ id: "not-existing-a-b-c-d", uid: "" });
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_POST_NOT_EXIST);
    }
  });
  it("Input test empty uid", async () => {
    try {
      await Post.delete({ id: post.id!, uid: "" });
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_NOT_YOUR_POST);
    }
  });
  it("Input test wrong uid", async () => {
    try {
      await Post.delete({ id: post.id!, uid: "wrong-uid-a-b-c-d" });
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_NOT_YOUR_POST);
    }
  });

  it("Input success mark as deleted", async () => {
    // update first to have 1 comment.
    await Post.update({ id: post.id, uid: uid, noOfComments: 1 });

    // will only be marked as deleted.
    const res = await Post.delete({ id: post.id!, uid: uid });
    expect(res.id).to.be.equals(post.id);

    // prove that it still exist, only marked as deleted.
    const postDoc = await Post.get(post.id!);
    expect(postDoc!.id).to.be.equals(post.id);
  });

  it("Input test wrong uid", async () => {
    try {
      await Post.delete({ id: post.id!, uid: uid });
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_ALREADY_DELETED);
    }
  });

  it("Input success completely deleted", async () => {
    const post = await Post.create({
      uid: uid,
      category: "cat1",
      title: "title",
      a: "apple",
    } as any);

    // since no comments, will be completely deleted.
    const res = await Post.delete({ id: post.id!, uid: uid });
    expect(res.id).to.be.equals(post.id);

    // prove that it does not exists.
    const postDoc = await Post.get(post.id!);
    expect(postDoc).to.be.equals(null);
  });

  it("Delete a post with image and thumbnail", async () => {
    const filename = "uploads/delete-test-" + Utils.getTimestamp();
    const file = await Storage.upload("./tests/storage/test.jpg", filename + ".jpg");
    const post = await Post.create({ uid: uid, category: "cat", files: [file.publicUrl()] });
    expect(post).to.be.an("object").to.have.property("files").lengthOf(1);

    expect((await file.exists())[0]).true;

    // wait for thumbnail image to be generated.
    await Utils.delay(2000);

    const thumb = Storage.getRefFromPath(filename + "_200x200.webp");
    expect((await thumb.exists())[0]).true;

    const obj = await Post.delete({ id: post.id!, uid: uid });
    expect(obj.id).equals(post.id!);

    expect((await file.exists())[0]).false;
    expect((await thumb.exists())[0]).false;
  });
});
