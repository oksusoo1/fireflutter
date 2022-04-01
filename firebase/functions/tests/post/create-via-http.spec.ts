import axios from "axios";

import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
// import { ERROR_EMPTY_UID } from "../../lib/defines";
// import { Post } from "../../src/classes/post";
import {
  ERROR_EMPTY_UID,
  ERROR_EMPTY_PASSWORD,
  ERROR_AUTH_FAILED,
  ERROR_EMPTY_CATEGORY,
} from "../../src/defines";
import { Utils } from "../../src/classes/utils";
import { User } from "../../src/classes/user";
// import { PostDocument } from "../../src/interfaces/forum.interface";

new FirebaseAppInitializer();

// const endpoint = "http://localhost:5001/withcenter-test-project/asia-northeast3/postCreate";
const endpoint = "https://asia-northeast3-withcenter-test-project.cloudfunctions.net/postCreate";
describe("Post create via http call", () => {
  it("empty uid", async () => {
    const res = await axios.post(endpoint);
    expect(res.data).equals(ERROR_EMPTY_UID);
  });
  it("empty password", async () => {
    const res = await axios.post(endpoint, { uid: "uid" });
    expect(res.data).equals(ERROR_EMPTY_PASSWORD);
  });
  it("auth failed", async () => {
    const res = await axios.post(endpoint, { uid: "uid", password: "wrong-password" });
    expect(res.data).equals(ERROR_AUTH_FAILED);
  });
  it("post create success", async () => {
    const id = "test-user-" + Utils.getTimestamp();
    await User.create(id, {
      firstName: "fn",
    });
    const user = await User.get(id);

    const res = await axios.post(endpoint, {
      uid: user!.id,
      password: user!.password,
    });
    expect(res.data).equals(ERROR_EMPTY_CATEGORY);
    const res2 = await axios.post(endpoint, {
      uid: user!.id,
      password: user!.password,
      category: "cat1",
      a: "apple",
      b: "banana",
    });
    const post = res2.data as any;
    expect(post.uid).equals(id);
    expect(post["a"]).equals("apple");
    console.log(post);
  });
});
