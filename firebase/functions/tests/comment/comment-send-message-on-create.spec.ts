import "mocha";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Post } from "../../src/classes/post";
import { Utils } from "../../src/classes/utils";
import { User } from "../../src/classes/user";
import { Test } from "../../src/classes/test";
import { Comment } from "../../src/classes/comment";
import { Messaging } from "../../src/classes/messaging";
import { Ref } from "../../src/classes/ref";

import { expect } from "chai";

new FirebaseAppInitializer();

const valToken =
  "fz-jn81hQoCNcFinQ80_vV%3AAPA91bGZ-6bS4na3cFDo201QW9Kkqha7VeHP8q-mkCwgqjhJv-yteIEnmYEyfdewnsi9eqx85weotQ2ZbDc_yKKV2iMHPEcDIhDbczzmftGCsY69lX6JCCR_a8_T_GGt67X8c2WG0yg0";

describe("Send message on comment create test", () => {
  // it('mock send on create', async () => {
  //     const stamp = Utils.getTimestamp();
  //     const a = "aMock-a-" + stamp;
  //     const b = "aMock-b-" + stamp;
  //     const c = "aMock-c-" + stamp;

  //     await User.create(a, { firstName: "uc-" + stamp });
  //     await User.create(b, { firstName: "uc-" + stamp });
  //     await User.create(c, { firstName: "uc-" + stamp });

  //     await Ref.userSettings(a).update({ [Messaging.commentNotificationField]: true });
  //     await Ref.userSettings(b).update({ [Messaging.commentNotificationField]: true });

  //     const category = await Test.createCategory();
  //     const post = await Post.create({
  //       uid: a,
  //       category: category.id,
  //       title: "oncreateCommentTest",
  //     } as any);

  //     const comment1 = await Comment.create({
  //       uid: b,
  //       postId: post!.id,
  //       parentId: post!.id,
  //       content: "first",
  //     } as any);

  //     const comment2 = await Comment.create({
  //       uid: c,
  //       postId: post!.id,
  //       parentId: comment1!.id,
  //       content: "second",
  //     } as any);

  //     // get comment ancestors
  //     const ancestorsUid = await Comment.getAncestorsUid(comment2!.id!, comment2!.uid);
  //     expect(ancestorsUid).include(comment1!.uid);

  //     // add the post uid if the comment author is not the post author
  //     if (post!.uid != comment2!.uid && !ancestorsUid.includes(post!.uid)) {
  //       ancestorsUid.push(post!.uid);
  //     }
  //     expect(ancestorsUid).include(post!.uid);

  //     const topic = "comments_" + post!.category;
  //     // Don't send the same message twice to topic subscribers and comment notifyees.
  //     const userUids = await Messaging.getUidsWithoutSubscription(ancestorsUid.join(","), "topic/forum/" + topic);
  //     expect(ancestorsUid.length).equal(2);

  //     // get uids with user setting commentNotification is set.
  //     const commentNotifyeesUids = await Messaging.getUidsWithSubscription(
  //       userUids.join(","),
  //       Messaging.commentNotificationField
  //     );
  //     expect(commentNotifyeesUids.length).equal(2);

  //     const valToken =
  //       "fz-jn81hQoCNcFinQ80_vV%3AAPA91bGZ-6bS4na3cFDo201QW9Kkqha7VeHP8q-mkCwgqjhJv-yteIEnmYEyfdewnsi9eqx85weotQ2ZbDc_yKKV2iMHPEcDIhDbczzmftGCsY69lX6JCCR_a8_T_GGt67X8c2WG0yg0";
  //     await Messaging.setToken({ uid: a, token: "fake-token-1" });
  //     await Messaging.setToken({ uid: b, token: valToken });
  //     // get users tokens
  //     const tokens = await Messaging.getTokensFromUids(commentNotifyeesUids.join(","));
  //     expect(tokens.length).equal(2);
  // })

  it("Sende Message on comment create", async () => {
    const stamp = Utils.getTimestamp();
    const a = "uc-a-" + stamp;
    const b = "uc-b-" + stamp;
    const c = "uc-c-" + stamp;

    await User.create(a, { firstName: "uc-" + stamp });
    await User.create(b, { firstName: "uc-" + stamp });
    await User.create(c, { firstName: "uc-" + stamp });

    await Ref.userSettings(a).update({ [Messaging.commentNotificationField]: true });
    await Ref.userSettings(b).update({ [Messaging.commentNotificationField]: true });

    const category = await Test.createCategory();
    const post = await Post.create({
      uid: a,
      category: category.id,
      title: "oncreateCommentTest",
    } as any);

    const comment1 = await Comment.create({
      uid: b,
      postId: post!.id,
      parentId: post!.id,
      content: "first",
    } as any);

    const comment2 = await Comment.create({
      uid: c,
      postId: post!.id,
      parentId: comment1!.id,
      content: "second",
    } as any);

    const topic = "comments_" + post!.category;

    const res1 = await Comment.sendMessageOnCreate(comment2!, comment2!.id!);
    console.log("res1", res1);
    if (res1) {
      expect(res1.topicResponse).not.empty.include("/project");
      expect(res1.tokenResponse.success).equal(0);
      expect(res1.tokenResponse.error).equal(0);
    } else {
      expect.fail("must not be null1");
    }

    await Messaging.setToken({ uid: a, token: "fake-token-1" });
    await Messaging.setToken({ uid: b, token: "fake-token-2" });
    const res2 = await Comment.sendMessageOnCreate(comment2!, comment2!.id!);

    if (res2) {
      expect(res2.topicResponse).not.empty.include("/project");
      expect(res2.tokenResponse.success).equal(0);
      expect(res2.tokenResponse.error).equal(2);
    } else {
      expect.fail("must not be null2,");
    }

    await Messaging.setToken({ uid: a, token: "fake-token-1" });
    await Messaging.setToken({ uid: b, token: "fake-token-2" });
    await Ref.userSetting(b, "topic/forum/").set({ [topic]: true });
    const res3 = await Comment.sendMessageOnCreate(comment2!, comment2!.id!);
    console.log("res3", res3);
    if (res3) {
      expect(res3.topicResponse).not.empty.include("/project");
      expect(res3.tokenResponse.success).equal(0);
      expect(res3.tokenResponse.error).equal(1);
    } else {
      expect.fail("must not be null3,");
    }

    await Messaging.setToken({ uid: b, token: valToken });
    await Ref.userSetting(b, "topic/forum/").set({ [topic]: false });
    const res4 = await Comment.sendMessageOnCreate(comment2!, comment2!.id!);
    console.log("res4", b);
    console.log(res4);
    if (res4) {
      expect(res4.topicResponse).not.empty.include("/project");
      expect(res4.tokenResponse.success).equal(0);
      expect(res4.tokenResponse.error).equal(2);
    } else {
      expect.fail("makesure set real token first");
    }
  });
});
