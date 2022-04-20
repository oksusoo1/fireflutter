import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Comment } from "../../src/classes/comment";
import { ERROR_EMPTY_UID } from "../../src/defines";
import { Test } from "../../src/classes/test";

new FirebaseAppInitializer();

describe("comment create test", () => {
  it("fail - empty uid", async () => {
    try {
      await Comment.create({} as any);
      expect.fail();
    } catch (e) {
      expect(e).equals(ERROR_EMPTY_UID);
    }
  });

  it("Succed to create a comment", async () => {
    const post = await Test.createPost();
    const comment = await Comment.create({
      uid: "a",
      postId: post!.id,
      parentId: "parent-id",
      content: "yo",
    } as any);
    // console.log(comment);
    expect(comment).not.to.be.null;
    expect(comment).to.be.an("object").to.have.property("id").to.be.string;
    expect(comment!.uid).equals("a");
    expect(comment.hasPhoto).to.be.an("boolean");
    expect(comment.hasPhoto).to.be.false;
    // console.log(await Post.get(post.id!));
  });
});
