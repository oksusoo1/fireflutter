import axios from "axios";

import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Utils } from "../../src/classes/utils";
import { User } from "../../src/classes/user";
import { PostDocument } from "../../src/interfaces/forum.interface";
import { Post } from "../../src/classes/post";
import {
  ERROR_EMPTY_ID,
  ERROR_EMPTY_PASSWORD,
  ERROR_EMPTY_UID,
  ERROR_NOT_YOUR_POST,
  ERROR_POST_NOT_EXIST,
  ERROR_USER_NOT_FOUND,
  ERROR_WRONG_PASSWORD,
} from "../../src/defines";

new FirebaseAppInitializer();

const endpoint = "http://localhost:5001/withcenter-test-project/asia-northeast3/postUpdate";
// const endpoint = "https://asia-northeast3-withcenter-test-project.cloudfunctions.net/postUpdate";

let post: PostDocument;
let password: string;
const uid = "test-user-" + Utils.getTimestamp();

describe("Post update via http call", () => {
  it("Prepare a post for updating (by creating a user)", async () => {
    await User.create(uid, {
      firstName: "fn",
    });
    const user = await User.get(uid);
    if (user === null) {
      expect.fail("User not exist by that uid.");
    }

    password = User.generatePassword(user);
    // console.log("password; ", password);

    post = await Post.create({
      uid: uid,
      password: password,
      category: "cat1",
      title: "title",
    } as any);

    expect(post).not.to.be.null;
    expect(post.category === "cat1").true;
    expect(post.title === "title").true;
  });

  it("fail - empty uid", async () => {
    const res = await axios.post(endpoint);
    expect(res.data.code).equals(ERROR_EMPTY_UID);
  });
  it("fail - empty password", async () => {
    const res = await axios.post(endpoint, { uid: "uid" });
    expect(res.data.code).equals(ERROR_EMPTY_PASSWORD);
  });
  it("fail - wrong password", async () => {
    const res = await axios.post(endpoint, { uid: "uid", password: "wrong-password" });
    expect(res.data.code).equals(ERROR_USER_NOT_FOUND);
  });

  it("fail - wrong password", async () => {
    const res = await axios.post(endpoint, { uid: uid, password: "some-password" });
    expect(res.data.code).equals(ERROR_WRONG_PASSWORD);
  });

  it("fail - error empty ID", async () => {
    const res = await axios.post(endpoint, { uid: uid, password: password });
    expect(res.data.code).equals(ERROR_EMPTY_ID);
  });

  it("fail - error comment does not exists", async () => {
    const res = await axios.post(endpoint, { uid: uid, password: password, id: "some-id" });
    expect(res.data.code).equals(ERROR_POST_NOT_EXIST);
  });

  it("fail - wrong post id (post does not exists)", async () => {
    const user = await User.get(uid);
    const password = User.generatePassword(user!);

    const res = await axios.post(endpoint, {
      id: "wrong-postid-does-not-exists",
      uid: uid,
      password: password,
    });

    expect(res.data.code).equals(ERROR_POST_NOT_EXIST);
  });

  it("fail - not your post", async () => {
    // create other user.
    const otherUserUid = "test-other-user-" + Utils.getTimestamp();
    await User.create(otherUserUid, { firstName: "Unit tester B" });
    const otherUser = await User.get(otherUserUid);
    const otherUserPassword = User.generatePassword(otherUser!);

    // update post using other user's credential.
    const res = await axios.post(endpoint, { uid: otherUser!.id, password: otherUserPassword, id: post!.id });
    expect(res.data.code).equals(ERROR_NOT_YOUR_POST);
  });

  it("success - post updated", async () => {
    await Utils.delay(2000);
    const updateA = await axios.post(endpoint, { uid: uid, password: password, id: post!.id, title: "World" });
    expect(updateA.data.title).is.not.equals(post!.title);
    expect(updateA.data.title).is.equals("World");

    // update title
    await Utils.delay(2000);
    const updateB = await axios.post(endpoint, { uid: uid, password: password, id: post!.id, title: "Hi mom!" });
    expect(updateB.data.title).is.not.equals(updateA.data.title);
    expect(updateB.data.title).is.equals("Hi mom!");

    expect((updateB.data.updatedAt! as any)["_seconds"]).is.not.equals((updateA.data.updatedAt! as any)["_seconds"]);
  });
});

