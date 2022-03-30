import * as admin from "firebase-admin";
import * as wonderfulKorea from "./wonderful-korea.config";

admin.initializeApp({
  databaseURL: wonderfulKorea.config.databaseURL,
});

// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", { structuredData: true });
//   response.send("Hello from Firebase!");
// });

export * from "./indexes/point.functions";
