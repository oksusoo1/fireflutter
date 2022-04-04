"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.testAnswer = void 0;
const functions = require("firebase-functions");
const quiz_1 = require("../classes/quiz");
exports.testAnswer = functions.region("asia-northeast3").https.onCall(async (data, context) => {
    return quiz_1.Quiz.testAnswer(data, context);
});
//# sourceMappingURL=quiz.functions.js.map