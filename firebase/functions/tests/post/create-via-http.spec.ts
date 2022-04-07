import axios from "axios";

import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
// import { ERROR_EMPTY_UID } from "../../lib/defines";
// import { Post } from "../../src/classes/post";
import {
  ERROR_EMPTY_UID,
  ERROR_EMPTY_PASSWORD,
  ERROR_EMPTY_CATEGORY,
  ERROR_USER_NOT_FOUND,
} from "../../src/defines";
import { Utils } from "../../src/classes/utils";
import { User } from "../../src/classes/user";
// import { PostDocument } from "../../src/interfaces/forum.interface";

new FirebaseAppInitializer();

const endpoint = "http://localhost:5001/withcenter-test-project/asia-northeast3/postCreate";
// const endpoint = "https://asia-northeast3-withcenter-test-project.cloudfunctions.net/postCreate";
describe("Post create via http call", () => {
  it("empty uid", async () => {
    const res = await axios.post(endpoint);
    expect(res.data).equals(ERROR_EMPTY_UID);
  });
  it("empty password", async () => {
    const res = await axios.post(endpoint, { uid: "uid" });
    expect(res.data).equals(ERROR_EMPTY_PASSWORD);
  });
  it("fail - wrong password", async () => {
    const res = await axios.post(endpoint, { uid: "uid", password: "wrong-password" });
    expect(res.data).equals(ERROR_USER_NOT_FOUND);
  });
  it("post create success", async () => {
    // Create a test user for creating a post.
    const id = "pcs-1-" + Utils.getTimestamp();
    await User.create(id, {
      firstName: "fn",
    });
    const user = await User.get(id);
    if (user === null) expect.fail();

    // test empty category
    const res = await axios.post(endpoint, {
      uid: user!.id,
      password: User.generatePassword(user),
    });

    expect(res.data).equals(ERROR_EMPTY_CATEGORY);

    // test creating a post
    const res2 = await axios.post(endpoint, {
      uid: user!.id,
      password: User.generatePassword(user),
      category: "cat1",
      a: "apple",
      b: "banana",
    });
    const post = res2.data as any;
    expect(post.uid).equals(id);
    expect(post["a"]).equals("apple");

    expect(post.password === undefined).true;
  });
});
