import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Post } from "../../src/classes/post";
import { PostDocument } from "../../src/interfaces/forum.interface";
import { Utils } from "../../src/classes/utils";

new FirebaseAppInitializer();

describe("Send message on post create test", () => {
  it("Sende Message on create", async () => {
    const postId = "onCreatePost" + Utils.getTimestamp();
    const post: PostDocument = {
      id: postId,
      uid: "onCreate",
      category: "cat1test",
      title: "Hello",
    };

    expect(post.id).equal(postId);
    const res = await Post.sendMessageOnPostCreate(post, postId);
    expect(res).to.be.an("string");
    expect(res).include("project/");
  });
});
