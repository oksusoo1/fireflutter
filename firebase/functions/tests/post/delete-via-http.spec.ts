import axios from "axios";

import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import {
  // ERROR_EMPTY_PASSWORD,
  //  ERROR_EMPTY_UID,
  ERROR_WRONG_PASSWORD,
} from "../../src/defines";
import { Utils } from "../../src/classes/utils";
import { User } from "../../src/classes/user";
import { PostDocument } from "../../src/interfaces/forum.interface";
import { Post } from "../../src/classes/post";
new FirebaseAppInitializer();

const endpoint = "http://localhost:5001/withcenter-test-project/asia-northeast3/postDelete";
// const endpoint = "https://asia-northeast3-withcenter-test-project.cloudfunctions.net/postDelete";

let post: PostDocument;
let password: string;
const uid = "test-user-" + Utils.getTimestamp();

describe("Post delete via http call", () => {
  it("Prepare a post for updating (by creating a user)", async () => {
    await User.create(uid, {
      firstName: "fn",
    });
    const user = await User.get(uid);
    console.log(user);
    password = User.generatePassword(user!);
    if (user === null) expect.fail();

    post = await Post.create({
      uid: user.id,
      category: "cat1",
      title: "title",
      a: "apple",
      noOfComments: 1,
      password: password,
    } as any);

    expect(post).not.to.be.null;
    expect(post!.category === "cat1").true;
    expect(post!.title === "title").true;
    expect(post!.a === "apple").true;
  });

  // it("empty uid", async () => {
  //   const res = await axios.post(endpoint);
  //   expect(res.data).equals(ERROR_EMPTY_UID);
  // });
  // it("empty password", async () => {
  //   const res = await axios.post(endpoint, { uid: uid });
  //   expect(res.data).equals(ERROR_EMPTY_PASSWORD);
  // });
  it("fail - wrong password", async () => {
    const res = await axios.post(endpoint, { uid: uid, password: "wrong-password" });
    expect(res.data).equals(ERROR_WRONG_PASSWORD);
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
  // it("fail - error no id", async () => {
  //   const res = await axios.post(endpoint, { uid: uid, password: password });
  //   expect(res.data).equals(ERROR_WRONG_PASSWORD);
  // });
});
