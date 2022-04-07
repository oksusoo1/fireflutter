import "mocha";
import { expect } from "chai";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Post } from "../../src/classes/post";
import { Utils } from "../../src/classes/utils";
import { Comment } from "../../src/classes/comment";
import { User } from "../../src/classes/user";
import { Messaging } from "../../src/classes/messaging";
import { Ref } from "../../src/classes/ref";

import { Test } from "../../src/classes/test";

new FirebaseAppInitializer();

const commentNotification = "newCommentUnderMyPostOrComment";

describe("Messaging test", () => {
  it("function test", async () => {
    const stamp = Utils.getTimestamp();
    const a = "uc-a-" + stamp;
    const b = "uc-b-" + stamp;
    const c = "uc-c-" + stamp;

    await User.create(a, { firstName: "uc-" + stamp });
    await User.create(b, { firstName: "uc-" + stamp });
    await User.create(c, { firstName: "uc-" + stamp });

    const post = await Post.create({
      uid: a,
      category: "cat1",
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

    // get comment ancestors
    const ancestorsUid = await Post.getCommentAncestors(comment2!.id, comment2!.uid);
    expect(ancestorsUid).include(comment1!.uid);

    // add the post uid if the comment author is not the post author
    if (post!.uid != comment2!.uid && !ancestorsUid.includes(post!.uid)) {
      ancestorsUid.push(post!.uid);
    }

    expect(ancestorsUid).include(post!.uid);
    const topic = "comments_" + post!.category;
    // Don't send the same message twice to topic subscribers and comment notifyees.
    const userUids = await Messaging.getCommentNotifyeeWithoutTopicSubscriber(ancestorsUid.join(","), topic);

    // get users tokens
    const tokens = await Messaging.getTokensFromUids(userUids.join(","));
    expect(tokens).is.empty;
  });

  it("Filtering uids with topic and forum subscriber", async () => {
    const timestamp = Utils.getTimestamp();
    const userA = "subscriberTestUserA" + timestamp;
    const userB = "subscriberTestUserB" + timestamp;
    const userC = "subscriberTestUserC" + timestamp;
    const userD = "subscriberTestUserD" + timestamp;
    const topic = "subscriberTopicTest" + timestamp;
    await Test.createTestUser(userA);
    await Test.createTestUser(userB);
    await Test.createTestUser(userC);
    await Test.createTestUser(userD);
    await Ref.userSettingTopic(userA).set({
      [commentNotification]: true,
    });
    await Ref.userSettingTopic(userB).set({
      [commentNotification]: true,
      [topic]: true,
    });
    await Ref.userSettingTopic(userC).set({
      [commentNotification]: false,
      [topic]: true,
    });
    await Ref.userSettingTopic(userD).set({
      [commentNotification]: true,
      [topic]: false,
    });

    const setTokens = [];
    setTokens.push(Ref.messageTokens.child(userA + "-wrong-token-id-").set({ uid: userA }));
    setTokens.push(Ref.messageTokens.child(userB + "-wrong-token-id-").set({ uid: userB }));
    setTokens.push(Ref.messageTokens.child(userC + "-wrong-token-id-").set({ uid: userC }));
    setTokens.push(Ref.messageTokens.child(userD + "-wrong-token-id-").set({ uid: userD }));
    await Promise.all(setTokens);

    const usersUid = [userA, userB, userC, userD];

    // remove subcriber uid but want to get notification under their post/comment
    let res = await Messaging.getCommentNotifyeeWithoutTopicSubscriber(usersUid.join(","), topic);
    expect(res.length).equal(2);
    expect(res).includes(userA).and.includes(userD);

    await Ref.userSettingTopic(userC).set({
      [commentNotification]: true,
      [topic]: false,
    });
    res = await Messaging.getCommentNotifyeeWithoutTopicSubscriber(usersUid.join(","), topic);
    expect(res.length).equal(3);
    expect(res).includes(userA).and.includes(userD).and.includes(userC);
  });

  //   // deploy first and provide valid 2 id.
  //   // need to provide 2 valid tokens
  //   // create UserA and UserB
  //   // set UserA  user settings to subscribe to get notified if new comment is
  //   // created under user post or comment
  //   // it creates 500 fake tokens
  //   // create post for userA
  //   // userB comment to userA post
  //   // functions onCommentCreate send push notification and remove invalid tokens
  //   // userA should only have 2 token(valid) after onCreate
  //   const base = 100; // put 100
  //   it("Sending messages of " + 5 * base + " tokens", async () => {
  //     const userA = "userA" + Utils.getTimestamp();
  //     const userB = "userB" + Utils.getTimestamp();
  //     await Test.createTestUser(userA);
  //     await Ref.userSettingTopic(userA).set({
  //       [commentNotification]: true,
  //     });

  //     await Ref.userSettingTopic(userB).set({
  //       [commentNotification]: false,
  //     });
  //     await Test.createTestUser(userB);
  //     const validToken1 =
  //       "djwdebPrQtm_u2N7jIygx3:APA91bHYJo7-bnbxHicRQOtT0kyyN42MRBaCk8WmrUFhsJhlHgI-xqgHzKnSL_ntr8WdvbeZCxwQLovATw972DzRAzlQ0H0Kx_iihU54VdP13cqYfaIX8DQGHnpbpW_OtWHutvD-MqeX";
  //     const validToken2 =
  //       "dT9S0cPbQ3OSRCbB8EG9li:APA91bHKVGQneklgn1baHTlE4xufYSdNrqt59JB4vRTxPYYjoGyiHhFkxBhYyE2sG6DFOCZ7oWEmne9GLKQje5YYCsLWIevg6W7kLQYl9gDERH6-s1Q_1C5vn5XCZf1mhdBr_KYPVKvX";
  //     const tokenUpdates = [];

  //     // set first valid token
  //     tokenUpdates.push(Ref.messageTokens.child(validToken1).set({ uid: userA }));

  //     // set 500 not valid token
  //     for (let i = 0; i < 5 * base; i++) {
  //       tokenUpdates.push(Ref.messageTokens.child("userA-wrong-token-id-" + i).set({ uid: userA }));
  //     }
  //     // set 2nd valid token
  //     tokenUpdates.push(Ref.messageTokens.child(validToken2).set({ uid: userA }));
  //     await Promise.all(tokenUpdates);

  //     const before = await Ref.messageTokens.orderByChild("uid").equalTo(userA).get();
  //     expect(before.hasChildren()).to.be.true;
  //     expect(Object.keys(before.val()).length).greaterThan(5 * base);

  //     // userA create parent post

  //     const postTest = await Post.create({
  //       category: { id: "test" },
  //       title: userA + "messaging test title",
  //       content: "yo",
  //       uid: userA,
  //     });

  //     const timestamp = Utils.getTimestamp();
  //     // userB create comment under userA post

  //     const commentTest1 = await Comment.create({
  //       postId: postTest!.id,
  //       parentId: postTest!.id,
  //       content: timestamp + " comment_content",
  //       uid: userB,
  //     });

  //     await Utils.delay(20000);
  //     const after = await Ref.messageTokens.orderByChild("uid").equalTo(userA).get();
  //     expect(Object.keys(after.val()).length).equal(2);

  //     const UserBtokenUpdates = [];
  //     // set 5 fake token
  //     for (let i = 0; i < 5; i++) {
  //       UserBtokenUpdates.push(Ref.messageTokens.child("userB-wrong-token-id-" + i).set({ uid: userB }));
  //     }
  //     await Promise.all(UserBtokenUpdates);

  //     const commentTest2 = await Comment.create({
  //       postId: postTest!.id,
  //       parentId: commentTest1!.id,
  //       content: timestamp + " comment_content by userA",
  //       uid: userA,
  //     });

  //     await Utils.delay(10000);
  //     const userBTokenCount = await Ref.messageTokens.orderByChild("uid").equalTo(userB).get();
  //     expect(Object.keys(userBTokenCount.val()).length).equal(5);
  //     await Ref.userSettingTopic(userB).set({
  //       [commentNotification]: true,
  //     });

  //     await Comment.create({
  //       postId: postTest!.id,
  //       parentId: commentTest2!.id,
  //       content: timestamp + " comment_content again by userA",
  //       uid: userA,
  //     });

  //     await Utils.delay(10000);
  //     const userBTokenCount2 = await Ref.messageTokens.orderByChild("uid").equalTo(userB).get();
  //     expect(userBTokenCount2.exists()).to.be.false;
  //   });
});
