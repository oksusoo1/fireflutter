import axios from "axios";

import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import {
  ERROR_ALREADY_DELETED,
  ERROR_EMPTY_ID,
  ERROR_EMPTY_PASSWORD,
  ERROR_EMPTY_UID,
  ERROR_POST_NOT_EXIST,
  ERROR_USER_NOT_FOUND,
  ERROR_WRONG_PASSWORD,
} from "../../src/defines";
import { Utils } from "../../src/classes/utils";
import { User } from "../../src/classes/user";
import { PostDocument } from "../../src/interfaces/forum.interface";
import { Post } from "../../src/classes/post";
import { UserDocument } from "../../src/interfaces/user.interface";
new FirebaseAppInitializer();

const endpoint = "http://localhost:5001/withcenter-test-project/asia-northeast3/postDelete";
// const endpoint = "https://asia-northeast3-withcenter-test-project.cloudfunctions.net/postDelete";

let post: PostDocument;
let user: UserDocument | null;
const uid = "test-user-" + Utils.getTimestamp();

describe("Post delete via http call", () => {
  it("Prepare a post for updating (by creating a user)", async () => {
    await User.create(uid, {
      firstName: "fn",
    });
    user = await User.get(uid);
    if (user === null) expect.fail();

    const password = User.generatePassword(user!);
    post = await Post.create({
      uid: user.id,
      category: "cat1",
      title: "title",
      a: "apple",
      password: password,
    } as any);

    expect(post).not.to.be.null;
    expect(post!.category === "cat1").true;
    expect(post!.title === "title").true;
    expect(post!.a === "apple").true;

    await Utils.delay(2000);
  });

  it("empty uid", async () => {
    const res = await axios.post(endpoint);
    expect(res.data).equals(ERROR_EMPTY_UID);
  });
  it("empty password", async () => {
    const res = await axios.post(endpoint, { uid: uid });
    expect(res.data).equals(ERROR_EMPTY_PASSWORD);
  });

  it("fail - wrong password", async () => {
    const res = await axios.post(endpoint, { uid: uid, password: "wrong-password" });
    expect(res.data).equals(ERROR_WRONG_PASSWORD);
  });
  it("fail - error wrong uid (not your post)", async () => {
    const user = await User.get(uid);
    const res = await axios.post(endpoint, { uid: "wrong-uid", password: User.generatePassword(user!) });
    expect(res.data).equals(ERROR_USER_NOT_FOUND);
  });

  /**
   * - input test
   *  - no id (error empty id)
   *  - wrong id test (post does not exists)
   */
  it("fail - error no post id", async () => {
    const user = await User.get(uid);
    const res = await axios.post(endpoint, { uid: uid, password: User.generatePassword(user!) });
    expect(res.data).equals(ERROR_EMPTY_ID);
  });
  it("fail - error wrong post id (does not exists)", async () => {
    const user = await User.get(uid);
    const res = await axios.post(endpoint, { uid: uid, password: User.generatePassword(user!), id: "does-not-exists" });
    expect(res.data).equals(ERROR_POST_NOT_EXIST);
  });
  /**
   *  - success (completely deleted)
   *  - correct uid (success delete, marked as deleted)
   *    - already deleted (already deleted)
   */
  it("success - post completely deleted", async () => {
    let user = await User.get(uid);
    let password = User.generatePassword(user!);

    // updated post first with 1 comment so it does not get completely deleted.
    const res = await axios.post(endpoint, { uid: uid, password: password, id: post.id });
    expect(res.data).equals(post.id);

    // prove it does not exists on database
    const postDoc = await Post.get(post.id!);
    expect(postDoc).equals(null);
  });
  it("success - post mark as deleted | fail - already deleted", async () => {
    let newPost: PostDocument;
    // update post.
    let user = await User.get(uid);
    let password = User.generatePassword(user!);
    // create
    newPost = await Post.create({
      uid: user!.id,
      category: "cat1",
      title: "title",
      a: "apple",
      password: password,
    });
    // then update to 1 comment, so it does not get completely deleted.
    await Post.update({ id: newPost.id, uid: uid, password: password, noOfComments: 1 });

    // request delete via http.
    user = await User.get(uid);
    password = User.generatePassword(user!);
    let res = await axios.post(endpoint, { id: newPost.id, uid: uid, password: password });

    expect(res.data).equals(newPost.id);

    // prove that it still exist, only marked as deleted.
    const postDoc = await Post.get(newPost.id!);
    expect(postDoc!.id).equals(newPost.id);
    expect(postDoc!.deleted).true;

    // try to delete again
    res = await axios.post(endpoint, { uid: uid, password: password, id: newPost.id });
    expect(res.data).equals(ERROR_ALREADY_DELETED);
  });
});
