import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { Point } from "./lib/point";
// import databaseUrlJson from "../../database-url.json";

// import { Point } from "./lib/point";

// console.log("databaseUrlJson; ", databaseUrlJson, databaseUrlJson.databaseURL);

admin.initializeApp({
  databaseURL: "https://withcenter-test-project-default-rtdb.asia-southeast1.firebasedatabase.app/",
});

// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", { structuredData: true });
//   response.send("Hello from Firebase!");
// });

/**
 * Listens for a user sign in and do point event.
 * A doc will be created at /point/{uid}/signIn/{pushId}
 *
 * @test How to test
 * % npm run shell
 * % pointEventSignIn({after: {lastLogin: 1234}}, {params: {uid: 'a'}})
 */
export const pointEventSignIn = functions
  .region("asia-northeast3")
  .database.ref("/users/{uid}/lastSignInAt")
  .onUpdate((change, context) => {
    // console.log("databaseUrlJson; ", databaseUrlJson, databaseUrlJson.databaseURL);

    return Point.signInPoint(change.after.val(), context);
  });
