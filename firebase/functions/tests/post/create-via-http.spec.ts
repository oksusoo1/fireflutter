import axios from "axios";

import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import {
  ERROR_EMPTY_UID,
  ERROR_EMPTY_PASSWORD,
  ERROR_EMPTY_CATEGORY,
  ERROR_USER_NOT_FOUND,
  ERROR_WRONG_PASSWORD,
} from "../../src/defines";
import { Utils } from "../../src/classes/utils";
import { User } from "../../src/classes/user";
import { Test } from "../../src/classes/test";

new FirebaseAppInitializer();

const uid = "pcs-1-" + Utils.getTimestamp();
let password: string;

const endpoint = "http://localhost:5001/withcenter-test-project/asia-northeast3/postCreate";
// const endpoint = "https://asia-northeast3-withcenter-test-project.cloudfunctions.net/postCreate";
describe("Post create via http call", () => {
  it("Prepares the test", async () => {
    // Create a test user for creating a post.
    await User.create(uid, {
      firstName: "fn",
    });

    const user = await User.get(uid);
    if (user === null) expect.fail();
    password = User.generatePassword(user!);
  });

  it("empty uid", async () => {
    const res = await axios.post(endpoint);
    expect(res.data.code).equals(ERROR_EMPTY_UID);
  });
  it("empty password", async () => {
    const res = await axios.post(endpoint, { uid: "uid" });
    expect(res.data.code).equals(ERROR_EMPTY_PASSWORD);
  });

  it("fail - user not found", async () => {
    const res = await axios.post(endpoint, { uid: "some-uid", password: "some-password" });
    expect(res.data.code).equals(ERROR_USER_NOT_FOUND);
  });

  it("fail - wrong password", async () => {
    const res = await axios.post(endpoint, { uid: uid, password: "some-password" });
    expect(res.data.code).equals(ERROR_WRONG_PASSWORD);
  });

  it("fail - empty category", async () => {
    // test empty category
    const res = await axios.post(endpoint, {
      uid: uid,
      password: password,
    });
    expect(res.data.code).equals(ERROR_EMPTY_CATEGORY);
  });

  it("post create success", async () => {
    // create user & category
    const user = await Test.createUser();
    const category = await Test.createCategory();

    // test creating a post
    const res = await axios.post(endpoint, {
      uid: user.id,
      password: User.generatePassword(user),
      category: category.id,
      a: "apple",
      b: "banana",
    });
    const post = res.data as any;

    expect(post.uid).equals(user.id);
    expect(post["a"]).equals("apple");

    expect(post.password === undefined).true;
  });
});
