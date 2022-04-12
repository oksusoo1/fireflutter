"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.quizUserAnswer = void 0;
const functions = require("firebase-functions");
const quiz_1 = require("../classes/quiz");
exports.quizUserAnswer = functions
    .region("us-central1", "asia-northeast3")
    .https.onCall(async (data, context) => {
    return quiz_1.Quiz.userAnswer(data, context);
});
//# sourceMappingURL=quiz.functions.js.map