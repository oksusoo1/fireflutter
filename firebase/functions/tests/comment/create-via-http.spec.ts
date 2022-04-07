import axios from "axios";
import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { ERROR_EMPTY_PASSWORD, ERROR_EMPTY_UID, ERROR_USER_NOT_FOUND, ERROR_WRONG_PASSWORD } from "../../src/defines";
import { User } from "../../src/classes/user";
import { Utils } from "../../src/classes/utils";

new FirebaseAppInitializer();

const uid = "test-user-" + Utils.getTimestamp();
let password: string;

const endpoint = "http://localhost:5001/withcenter-test-project/asia-northeast3/commentCreate";
// const endpoint = "https://asia-northeast3-withcenter-test-project.cloudfunctions.net/postCreate";
describe("comment create via http test", () => {
  it("Prepares the test", async () => {
    await User.create(uid, { firstName: "Unit tester" });
    const user = await User.get(uid);
    password = User.generatePassword(user!);
  });

  it("fail - empty uid", async () => {
    const res = await axios.post(endpoint, {});
    expect(res.data.code).equals(ERROR_EMPTY_UID);
  });

  it("fail - empty password", async () => {
    const res = await axios.post(endpoint, { uid: "some-uid" });
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

  it("success - create comment", async () => {
    const res = await axios.post(endpoint, { uid: uid, password: password });
    expect(res.data.uid).equals(uid);

    const res2 = await axios.post(endpoint, { uid: uid, password: password, content: "Hi mom!" });
    expect(res2.data.uid).equals(uid);
    expect(res2.data.content).equals("Hi mom!");
  });
});
