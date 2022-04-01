import * as functions from "firebase-functions";
import { Quiz } from "../classes/quiz";

export const testAnswer = functions.region("asia-northeast3").https.onCall(async (data, context) => {
  return Quiz.testAnswer(data, context);
});
