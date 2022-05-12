import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Post } from "../../src/classes/post";

import { Test } from "../../src/classes/test";
import { Comment } from "../../src/classes/comment";
import { Utils } from "../../src/classes/utils";

new FirebaseAppInitializer();

describe("Post view test", () => {
  it("test if author information is added", async () => {
    const category = await Test.createCategory();

    const created = await Post.create({
      uid: "a",
      password: "abc",
      category: category.id,
      title: "yo",
      a: "apple",
    } as any);

    const comment = await Comment.create({
      postId: created.id!,
      parentId: created.id!,
      uid: "a",
      content: "first comment",
    });

    await Utils.delay(1000);
    const comment2 = await Comment.create({
      postId: created.id!,
      parentId: created.id!,
      uid: "a",
      content: "second comment",
    });

    await Utils.delay(1000);

    const reply = await Comment.create({
      postId: created.id!,
      parentId: comment.id!,
      uid: "a",
      content: "reply on first comment",
    });

    await Utils.delay(3000);

    const post = await Post.view({ id: created.id! });

    expect("author" in post).true;
    expect("authorLevel" in post).true;
    expect("authorPhotoUrl" in post).true;

    // post must have 3 comments
    expect(post.comments.length === 3).true;

    // comments must have author information (name, level, photoUrl)
    expect("author" in post.comments[0]).true;
    expect("authorLevel" in post.comments[0]).true;
    expect("authorPhotoUrl" in post.comments[0]).true;

    // expect proper precedence.
    expect(post.comments[0].id === comment.id).true;
    expect(post.comments[0].depth === 0).true;
    expect(post.comments[1].id === reply.id).true;
    expect(post.comments[1].depth === 1).true;
    expect(post.comments[2].id === comment2.id).true;
    expect(post.comments[2].depth === 0).true;

    // Cleanup
    Comment.delete(reply.id!);
    Comment.delete(comment2.id!);
    Comment.delete(comment.id!);
    Post.delete({ id: post.id!, uid: post.uid });
  });
});
