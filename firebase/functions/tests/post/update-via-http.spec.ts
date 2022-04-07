import axios from "axios";

import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Utils } from "../../src/classes/utils";
import { User } from "../../src/classes/user";
import { PostDocument } from "../../src/interfaces/forum.interface";
import { Post } from "../../src/classes/post";
import {
  ERROR_EMPTY_PASSWORD,
  ERROR_EMPTY_UID,
  ERROR_POST_NOT_EXIST,
  ERROR_USER_NOT_FOUND,
} from "../../src/defines";
import { UserDocument } from "../../src/interfaces/user.interface";

new FirebaseAppInitializer();

const endpoint = "http://localhost:5001/withcenter-test-project/asia-northeast3/postUpdate";
// const endpoint = "https://asia-northeast3-withcenter-test-project.cloudfunctions.net/postUpdate";

let post: PostDocument;
let user: UserDocument | null;
const uid = "test-user-" + Utils.getTimestamp();

describe("Post update via http call", () => {
  it("Prepare a post for updating (by creating a user)", async () => {
    await User.create(uid, {
      firstName: "fn",
    });
    user = await User.get(uid);
    if (user === null) {
      expect.fail("User not exist by that uid.");
    }

    const password = User.generatePassword(user);
    // console.log("password; ", password);

    post = await Post.create({
      uid: user.id,
      password: password,
      category: "cat1",
      title: "title",
    } as any);

    expect(post).not.to.be.null;
    expect(post.category === "cat1").true;
    expect(post.title === "title").true;
  });

  it("empty uid", async () => {
    const res = await axios.post(endpoint);
    expect(res.data.code).equals(ERROR_EMPTY_UID);
  });
  it("empty password", async () => {
    const res = await axios.post(endpoint, { uid: "uid" });
    expect(res.data.code).equals(ERROR_EMPTY_PASSWORD);
  });
  it("fail - wrong password", async () => {
    const res = await axios.post(endpoint, { uid: "uid", password: "wrong-password" });
    expect(res.data.code).equals(ERROR_USER_NOT_FOUND);
  });

  it("fail - wrong post id (post does not exists)", async () => {
    user = await User.get(uid!);
    const password = User.generatePassword(user!);
    // console.log("password; ", password);
    const res = await axios.post(endpoint, {
      id: "wrong-postid-does-not-exists",
      uid: uid,
      password: password,
    });

    expect(res.data.code).equals(ERROR_POST_NOT_EXIST);
  });
});
