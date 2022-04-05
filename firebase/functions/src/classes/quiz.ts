import * as functions from "firebase-functions";
import { CallableContext } from "firebase-functions/v1/https";
import { ERROR_CANNOT_ANSWER_SAME_QUESTION_TWICE, ERROR_LOGIN_FIRST, ERROR_NO_QUIZ_BY_THAT_ID } from "../defines";
import { QuizAnswer, QuizResult } from "../interfaces/quiz.interface";

import { Ref } from "./ref";

export class Quiz {
  /**
   * @logic
   *  - 1. Get the question and answer
   *  - 2. Check if the answered correct, or wrong.
   *  - 3. Check if the user answered same question twice.
   *  - 4. Save the question.
   *  - If it's correct, increase user point
   * @param data document data
   * @param context context
   *
   * @returns
   *  - `true` if the user answered correctly.
   *  - `false` if not.
   */
  static async userAnswer(data: QuizAnswer, context: CallableContext): Promise<QuizResult> {
    if (!context.auth) {
      throw new functions.https.HttpsError(
          "failed-precondition",
          ERROR_LOGIN_FIRST,
          // User is not logged in,
      );
    }

    const quizId = Object.keys(data)[0];
    const userAnswer = data[quizId].answer;

    // 1.
    const quizDoc = (await Ref.db.collection("/posts/").doc(quizId).get()).data();

    // console.log("quizDoc", quizDoc);
    if (typeof quizDoc === "undefined") {
      throw new functions.https.HttpsError(
          "failed-precondition",
          ERROR_NO_QUIZ_BY_THAT_ID
      );
    }

    // 2.
    const re = quizDoc.answer === userAnswer;
    // console.log("re; ", re);

    // 3.

    const userQuizRef = Ref.db.collection("quiz-history").doc(context.auth!.uid);
    const userQuizData = await userQuizRef.get();
    if (userQuizData.exists) {
      const userQuizDoc = userQuizData.data();

      if (Object.keys(userQuizDoc!).indexOf(quizId) != -1) {
        throw new functions.https.HttpsError(
            "failed-precondition",
            ERROR_CANNOT_ANSWER_SAME_QUESTION_TWICE
        );
      }
    }

    await userQuizRef.set(
        {
          [quizId]: {
            answer: userAnswer,
            result: re,
          },
        },
        { merge: true }
    );
    return {
      quizId: quizId,
      answer: userAnswer,
      result: re,
    };
  }
}
