import axios from "axios";
import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import {
  ERROR_COMMENT_NOT_EXISTS,
  ERROR_EMPTY_ID,
  ERROR_EMPTY_PASSWORD,
  ERROR_EMPTY_UID,
  ERROR_NOT_YOUR_COMMENT,
  ERROR_USER_NOT_FOUND,
  ERROR_WRONG_PASSWORD,
} from "../../src/defines";
import { User } from "../../src/classes/user";
import { Utils } from "../../src/classes/utils";
import { CommentDocument } from "../../src/interfaces/forum.interface";
import { Comment } from "../../src/classes/comment";

new FirebaseAppInitializer();

const uid = "test-user-" + Utils.getTimestamp();
let password: string;

let comment: CommentDocument | null;

const endpoint = "http://localhost:5001/withcenter-test-project/asia-northeast3/commentDelete";
// const endpoint = "https://asia-northeast3-withcenter-test-project.cloudfunctions.net/commentDelete";
describe("comment create via http test", () => {
  it("Prepares the test", async () => {
    await User.create(uid, { firstName: "Unit tester" });
    const user = await User.get(uid);
    expect(user).is.not.null;

    comment = await Comment.create({
      uid: uid,
      content: "Hello",
    } as any);
    expect(comment).is.not.null;
    expect(comment!.uid).equals(user!.id);

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

  it("fail - error empty ID", async () => {
    const res = await axios.post(endpoint, { uid: uid, password: password });
    expect(res.data.code).equals(ERROR_EMPTY_ID);
  });

  it("fail - error comment does not exists", async () => {
    const res = await axios.post(endpoint, { uid: uid, password: password, id: "some-id" });
    expect(res.data.code).equals(ERROR_COMMENT_NOT_EXISTS);
  });

  it("fail - not your comment", async () => {
    // create other user
    const otherUserUid = "test-other-user-" + Utils.getTimestamp();
    await User.create(otherUserUid, { firstName: "Unit tester B" });
    const otherUser = await User.get(otherUserUid);
    const otherUserPassword = User.generatePassword(otherUser!);

    // delete comment using other user's credentials
    const res = await axios.post(endpoint, { uid: otherUserUid, password: otherUserPassword, id: comment!.id });
    expect(res.data.code).equals(ERROR_NOT_YOUR_COMMENT);
  });

  it("success - comment delete", async () => {
    const res = await axios.post(endpoint, { uid: uid, password: password, id: comment!.id });
    expect(res.data.id).equals(comment!.id);

    // prove post is deleted
    const commentDoc = await Comment.get(comment!.id);
    expect(commentDoc).is.not.null;
    expect(commentDoc!.deleted).true;
  });
});
