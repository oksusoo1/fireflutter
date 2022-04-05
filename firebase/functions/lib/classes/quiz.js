"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Quiz = void 0;
const functions = require("firebase-functions");
const defines_1 = require("../defines");
const ref_1 = require("./ref");
class Quiz {
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
    static async userAnswer(data, context) {
        if (!context.auth) {
            throw new functions.https.HttpsError("failed-precondition", defines_1.ERROR_LOGIN_FIRST);
        }
        const quizId = Object.keys(data)[0];
        const userAnswer = data[quizId].answer;
        // 1.
        const quizDoc = (await ref_1.Ref.db.collection("/posts/").doc(quizId).get()).data();
        // console.log("quizDoc", quizDoc);
        if (typeof quizDoc === "undefined") {
            throw new functions.https.HttpsError("failed-precondition", defines_1.ERROR_NO_QUIZ_BY_THAT_ID);
        }
        // 2.
        const re = quizDoc.answer === userAnswer;
        // console.log("re; ", re);
        // 3.
        const userQuizRef = ref_1.Ref.db.collection("quiz-history").doc(context.auth.uid);
        const userQuizData = await userQuizRef.get();
        if (userQuizData.exists) {
            const userQuizDoc = userQuizData.data();
            if (Object.keys(userQuizDoc).indexOf(quizId) != -1) {
                throw new functions.https.HttpsError("failed-precondition", defines_1.ERROR_CANNOT_ANSWER_SAME_QUESTION_TWICE);
            }
        }
        await userQuizRef.set({
            [quizId]: {
                answer: userAnswer,
                result: re,
            },
        }, { merge: true });
        return {
            quizId: quizId,
            answer: userAnswer,
            result: re,
        };
    }
}
exports.Quiz = Quiz;
//# sourceMappingURL=quiz.js.map