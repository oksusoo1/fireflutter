import "mocha";
import { expect } from "chai";
import { Ref } from "../../src/classes/ref";
import { Utils } from "../../src/classes/utils";
import { FirebaseAppInitializer } from "../firebase-app-initializer";

import { Test } from "../../src/classes/test";
import { Quiz } from "../../src/classes/quiz";
import {
  ERROR_CANNOT_ANSWER_SAME_QUESTION_TWICE,
  ERROR_LOGIN_FIRST,
  ERROR_NO_QUIZ_BY_THAT_ID,
} from "../../src/defines";

new FirebaseAppInitializer();

describe("Quiz test", () => {
  it("Tests quiz answer expect success.", async () => {
    const uid = "test-uid-" + Utils.getTimestamp();

    // create test user
    // create test questions
    await Test.createTestUser(uid);
    // console.log(user.key);
    const questionA = await Ref.db.collection("posts").add({
      category: "quiz",
      title: "Test question",
      a: "a",
      b: "b",
      c: "c",
      answer: "a",
    });
    const questionB = await Ref.db.collection("posts").add({
      category: "quiz",
      title: "Test question",
      a: "right",
      b: "wrong",
      answer: "a",
    });

    // user answer questionA with a, expect result true.
    const questionResultA = await Quiz.userAnswer(
        {
          [questionA.id]: {
            answer: "a",
          },
        },
      { auth: { uid: uid } } as any
    );
    expect(questionResultA.result).to.be.equal(true);

    // user answers questionB with b, expect result false.
    const questionResultB = await Quiz.userAnswer(
        {
          [questionB.id]: {
            answer: "b",
          },
        },
      { auth: { uid: uid } } as any
    );
    expect(questionResultB.result).to.be.equal(false);

    // cleanup
    await Ref.db.collection("posts").doc(questionA.id).delete();
    await Ref.db.collection("posts").doc(questionB.id).delete();
    await Ref.db.collection("quiz-history").doc(uid).delete();
    await Test.deleteTestUser(uid);
  });

  it("Tests error on non existent quiz id.", async () => {
    let res: any;
    try {
      res = await Quiz.userAnswer(
          {
            "testQuiz-id": { answer: "b" },
          },
        { auth: { uid: "test-uid" } } as any
      );
    } catch (e) {
      res = e;
    }

    expect(res.message).to.be.equal(ERROR_NO_QUIZ_BY_THAT_ID);
  });

  it("Tests error on login first.", async () => {
    let res: any;
    try {
      res = await Quiz.userAnswer({}, {} as any);
    } catch (e) {
      res = e;
    }

    expect(res.message).to.be.equal(ERROR_LOGIN_FIRST);
  });

  it("Tests error on cannot answer same question", async () => {
    const uid = "test-uid-" + Utils.getTimestamp();

    // create test user
    // create test question
    await Test.createTestUser(uid);
    const question = await Ref.db.collection("posts").add({
      category: "quiz",
      title: "Test question",
      a: "right",
      b: "wrong",
      answer: "a",
    });

    // user answer 1 time
    let answerResult = await Quiz.userAnswer(
        {
          [question.id]: {
            answer: "a",
          },
        },
      { auth: { uid: uid } } as any
    );
    expect(answerResult.result).to.be.equal(true);

    // user answers second time on same question.
    let re: any;
    try {
      answerResult = await Quiz.userAnswer(
          {
            [question.id]: {
              answer: "b",
            },
          },
        { auth: { uid: uid } } as any
      );
    } catch (e) {
      re = e;
    }
    expect(re.message).to.be.equal(ERROR_CANNOT_ANSWER_SAME_QUESTION_TWICE);

    // cleanup
    await Ref.db.collection("posts").doc(question.id).delete();
    await Ref.db.collection("quiz-history").doc(uid).delete();
    await Test.deleteTestUser(uid);
  });
});
