/**
 * @file foum.functions.ts
 *
 * HTTP events for forum functions.
 * (Calling functions via HTTP request, HTTP trigger)
 *
 * CORS
 *  By design, http calls are allowed only from same domain.
 *  If client is from different domain, you need cors.
 *
 * Preflight
 *  By design, only allowed HTTP methods could be made.
 *
 *
 *
 */
import * as functions from "firebase-functions";
import { cors } from "../cors";

// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript

export const date = functions.region("asia-northeast3").https.onRequest((req, res) => {
  cors(req, res, () => {
    res.send("Hello World!");
  });
});
