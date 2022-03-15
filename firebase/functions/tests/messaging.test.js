"use strict";

const mocha = require("mocha");
const describe = mocha.describe;
const it = mocha.it;

const assert = require("assert");

// const functions = require("firebase-functions");
const admin = require("firebase-admin");

// initialize the firebase
if (!admin.apps.length) {
  const serviceAccount = require("../../firebase-admin-sdk-key.json");
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL:
      "https://withcenter-test-project-default-rtdb.asia-southeast1.firebasedatabase.app/",
  });
}
// This must come after initlization

const test = require("../test");
const lib = require("../lib");

// get firestore
const db = admin.firestore();

// get real time database
const rdb = admin.database();

const commentNotification = "newCommentUnderMyPostOrComment";

const base = 1; // put 100

describe("Messaging ~~~~~~~~~~~~~~~~", () => {
  it("get comment anscestor uid", async () => {
    await test.createComment({
      category: {
        id: "test",
      },
      post: {
        id: "Pid-1",
        title: "post_title",
        uid: "A",
      },
      comment: {
        id: "Cid-1",
        postId: "Pid-1",
        parentId: "Pid-1",
        content: "comment_content",
        uid: "B",
      },
    });

    await test.createComment({
      comment: {
        id: "Cid-2",
        postId: "Pid-1",
        parentId: "Cid-1",
        content: "comment_content",
        uid: "B",
      },
    });

    let res = await lib.getCommentAncestors("Cid-2", "C");

    assert.ok(res.length == 1 && res[0] == "B");

    // expect ok. res.length == 1
    // Add a comment with same author uid.
    await test.createComment({
      comment: {
        id: "Cid-3",
        postId: "Pid-1",
        parentId: "Cid-2",
        uid: "C",
      },
    });
    res = await lib.getCommentAncestors("Cid-3", "C");
    assert.ok(res.length == 1 && res[0] == "B");

    // expect ok. res.length == 1.
    // Add a comment with different author, but still result is 1 since the current
    // comment is excluded.
    await test.createComment({
      comment: {
        id: "Cid-4",
        postId: "Pid-1",
        parentId: "Cid-3",
        uid: "D",
      },
    });
    res = await lib.getCommentAncestors("Cid-4", "C");
    assert.ok(res.length == 1 && res[0] == "B");

    // expect ok. res.length == 2.
    // Add a comment with different author
    await test.createComment({
      comment: {
        id: "Cid-5",
        postId: "Pid-1",
        parentId: "Cid-4",
        uid: "E",
      },
    });
    res = await lib.getCommentAncestors("Cid-5", "C");
    assert.ok(res.length == 2 && res[0] == "D" && res[1] == "B");
  });

  // need to provide 2 valid tokens
  // create UserA and UserB
  // set UserA  user settings to subscribe to get notified if new comment is
  // created under user post or comment
  // it creates 500 fake tokens
  // create post for userA
  // userB comment to userA post
  // functions onCommentCreate send push notification and remove invalid tokens
  // userA should only have 2 token(valid) after onCreate
  it("Sending messages of " + 5 * base +" tokens", async () => {
    const userA = "userA";
    const userB = "userB";
    await test.createTestUser(userA);
    await rdb
        .ref("user-settings")
        .child(userA)
        .child("topic")
        .set({
          [commentNotification]: true,
        });

    await rdb
        .ref("user-settings")
        .child(userB)
        .child("topic")
        .set({
          [commentNotification]: false,
        });
    await test.createTestUser(userB);
    const validToken1 =
      "djwdebPrQtm_u2N7jIygx3:APA91bHYJo7-bnbxHicRQOtT0kyyN42MRBaCk8WmrUFhsJhlHgI-xqgHzKnSL_ntr8WdvbeZCxwQLovATw972DzRAzlQ0H0Kx_iihU54VdP13cqYfaIX8DQGHnpbpW_OtWHutvD-MqeX";
    const validToken2 =
      "dT9S0cPbQ3OSRCbB8EG9li:APA91bHKVGQneklgn1baHTlE4xufYSdNrqt59JB4vRTxPYYjoGyiHhFkxBhYyE2sG6DFOCZ7oWEmne9GLKQje5YYCsLWIevg6W7kLQYl9gDERH6-s1Q_1C5vn5XCZf1mhdBr_KYPVKvX";
    const tokenUpdates = [];


    // set first valid token
    tokenUpdates.push(rdb.ref("message-tokens").child(validToken1).set({uid: userA}));

    // set 500 not valid token
    for (let i = 0; i < 5 * base; i++) {
      tokenUpdates.push(
          rdb
              .ref("message-tokens")
              .child("userA-wrong-token-id-" + i)
              .set({uid: userA}),
      );
    }
    // set 2nd valid token
    tokenUpdates.push(rdb.ref("message-tokens").child(validToken2).set({uid: userA}));
    await Promise.all(tokenUpdates);

    const before = await rdb.ref("message-tokens").orderByChild("uid").equalTo(userA).get();
    assert.ok(before.hasChildren(), "must have data:: " + before.size);
    assert.ok(Object.keys(before.val()).length > 5 * base, "should be " + (5 * base) + " got:: " +Object.keys(before.val()).length);

    // userA create parent post
    const postTestId = "postTestId";
    await test.createPost({
      category: {id: "test"},
      post: {
        title: userA + "messaging test title",
        content: "yo",
        uid: userA,
        id: postTestId,
      },
    });

    const timestamp = new Date().getTime();
    // userB create comment under userA post
    const commentTest1Id = "commentTest1Id";
    await test.createComment({
      comment: {
        id: commentTest1Id + timestamp,
        postId: postTestId,
        parentId: postTestId,
        content: commentTest1Id + timestamp + " comment_content",
        uid: userB,
      },
    });

    await lib.delay(20000);
    const after = await rdb.ref("message-tokens").orderByChild("uid").equalTo(userA).get();
    console.log(after.val());
    assert.ok(Object.keys(after.val()).length == 2, "should only have 2 left, got: " + Object.keys(after.val()).length);

    const UserBtokenUpdates = [];
    // set 5 fake token
    for (let i = 0; i < 5; i++) {
      UserBtokenUpdates.push(
          rdb
              .ref("message-tokens")
              .child("userB-wrong-token-id-" + i)
              .set({uid: userB}),
      );
    }
    await Promise.all(UserBtokenUpdates);

    const commentTest2Id = "commentTest2Id";
    await test.createComment({
      comment: {
        id: commentTest2Id + timestamp,
        postId: postTestId,
        parentId: commentTest1Id + timestamp,
        content: commentTest2Id + timestamp + " comment_content by userA",
        uid: userA,
      },
    });

    await lib.delay(10000);
    const userBTokenCount = await rdb.ref("message-tokens").orderByChild("uid").equalTo(userB).get();
    console.log(userBTokenCount.val());
    assert.ok(Object.keys(userBTokenCount.val()).length == 5, "must have 5 tokens, got: " + Object.keys(userBTokenCount.val()).length);
    await rdb
        .ref("user-settings")
        .child(userB)
        .child("topic")
        .set({
          [commentNotification]: true,
        });

    const commentTest3Id = "commentTest3Id";
    await test.createComment({
      comment: {
        id: commentTest3Id + timestamp,
        postId: postTestId,
        parentId: commentTest2Id + timestamp,
        content: commentTest3Id + timestamp + " comment_content again by userA",
        uid: userA,
      },
    });

    await lib.delay(10000);
    const userBTokenCount2 = await rdb.ref("message-tokens").orderByChild("uid").equalTo(userB).get();
    assert.ok(!userBTokenCount2.exists(),
        "must have 0 token by this time," 
    );
  });

  it("Filtering uids with topic and forum subscriber", async () => {
    const userA = "subscriberTestUserA";
    const userB = "subscriberTestUserB";
    const userC = "subscriberTestUserC";
    const userD = "subscriberTestUserD";
    const topic = "subscriberTopicTest";
    await test.createTestUser(userA);
    await test.createTestUser(userB);
    await test.createTestUser(userC);
    await test.createTestUser(userD);
    await rdb
        .ref("user-settings")
        .child(userA)
        .child("topic")
        .set({
          [commentNotification]: true,
        });
    await rdb
        .ref("user-settings")
        .child(userB)
        .child("topic")
        .set({
          [commentNotification]: true,
          [topic]: true,
        });
    await rdb
        .ref("user-settings")
        .child(userC)
        .child("topic")
        .set({
          [commentNotification]: false,
          [topic]: true,
        });
    await rdb
        .ref("user-settings")
        .child(userD)
        .child("topic")
        .set({
          [commentNotification]: true,
          [topic]: false,
        });

    const setTokens = [];
    setTokens.push(
        rdb
            .ref("message-tokens")
            .child(userA + "-wrong-token-id-")
            .set({uid: userA}),
    );
    setTokens.push(
        rdb
            .ref("message-tokens")
            .child(userB + "-wrong-token-id-")
            .set({uid: userB}),
    );
    setTokens.push(
        rdb
            .ref("message-tokens")
            .child(userC + "-wrong-token-id-")
            .set({uid: userC}),
    );
    setTokens.push(
        rdb
            .ref("message-tokens")
            .child(userD + "-wrong-token-id-")
            .set({uid: userD}),
    );
    await Promise.all(setTokens);

    const usersUid = [userA, userB, userC, userD];

    // remove subcriber uid but want to get notification under their post/comment
    let res = await lib.getCommentNotifyeeWithoutTopicSubscriber(usersUid, topic);
    assert.ok(res.length == 2, "userA and userD must get notified");
    assert.ok(res.includes(userA) && res.includes(userD));

    await rdb
        .ref("user-settings")
        .child(userC)
        .child("topic")
        .set({
          [commentNotification]: true,
          [topic]: false,
        });
    res = await lib.getCommentNotifyeeWithoutTopicSubscriber(usersUid, topic);
    assert.ok(res.length == 3, "userA and userD must get notified and userC this time");
    assert.ok(res.includes(userA) && res.includes(userD) && res.includes(userC));
  });
});
