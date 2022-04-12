import * as functions from "firebase-functions";
import { Quiz } from "../classes/quiz";

export const quizUserAnswer = functions
    .region("us-central1", "asia-northeast3")
    .https.onCall(async (data, context) => {
      return Quiz.userAnswer(data, context);
    });
