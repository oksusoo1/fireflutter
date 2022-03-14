"use strict";
const mocha = require("mocha");
const describe = mocha.describe;
const it = mocha.it;

const assert = require("assert");

// const assert = require("assert");
const admin = require("firebase-admin");

// initialize the firebase
if (!admin.apps.length) {
  const serviceAccount = require("../../firebase-admin-sdk-key.json");
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://wonderful-korea-default-rtdb.asia-southeast1.firebasedatabase.app/",
  });
}

// get firestore
// const db = admin.firestore();

// This must come after initlization
const test = require("../test");
const lib = require("../lib");

// get firestore
const db = admin.firestore();

describe("Test test", () => {
  it("Prepare user and question", async () => {
    const ref = await test.createTestUser("userA");
    const data = (await ref.get()).val();
    assert.ok(data.registeredAt);

    await db.collection("posts").doc("0-quiz-A").set(
        {
          title: "question title",
          answer: "a",
          a: "apple",
          b: "banana",
        },
        {merge: true},
    );
  });

  it("Wrong quiz - quiz does not exists by that id", async () => {
    try {
      await lib.testAnswer({wrongQuizId: {answer: "e"}}, {auth: {uid: "userA"}});
      assert.ok(false);
    } catch (e) {
      assert.ok(e.message === "ERROR_NO_QUIZ_BY_THAT_ID");
    }
  });
  it("Wrong answer", async () => {
    const quizId = "0-quiz-A";
    const userQuizRef = db.collection("quiz-history").doc("userA");
    await userQuizRef.delete();
    const res = await lib.testAnswer({[quizId]: {answer: "e"}}, {auth: {uid: "userA"}});
    const doc = (await userQuizRef.get()).data();
    assert.ok(res.result === false);
    assert.ok(doc[quizId].result == false);
  });
  it("Correct answer", async () => {
    const quizId = "0-quiz-A";
    const userQuizRef = db.collection("quiz-history").doc("userA");
    await userQuizRef.delete();
    const res = await lib.testAnswer({[quizId]: {answer: "a"}}, {auth: {uid: "userA"}});
    const doc = (await userQuizRef.get()).data();
    assert.ok(res.result === true);
    assert.ok(doc[quizId].result == true);
  });
  it("Answering same question twice is not allowed.", async () => {
    const quizId = "0-quiz-A";
    const userQuizRef = db.collection("quiz-history").doc("userA");
    await userQuizRef.delete();
    await lib.testAnswer({[quizId]: {answer: "a"}}, {auth: {uid: "userA"}});

    try {
      await lib.testAnswer({[quizId]: {answer: "a"}}, {auth: {uid: "userA"}});
    } catch (e) {
      assert.ok(e.message === "ERROR_CANNOT_ANSWER_SAME_QUESTION_TWICE");
    }
  });
});
