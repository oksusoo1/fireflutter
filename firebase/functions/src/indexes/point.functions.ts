import * as functions from "firebase-functions";
import { Point } from "../library/point";

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
      return Point.signInPoint(change.after.val(), context);
    });

/**
 * Listens for a new user to be register(created) at /users/:uid and do point event.
 * A doc will be created at /point/{uid}/register
 *
 * @test How to test
 * % npm run shell
 * % pointEventRegister({}, {params: {uid: 'a'}})
 */
exports.pointEventRegister = functions
    .region("asia-northeast3")
    .database.ref("/users/{uid}")
    .onCreate((snapshot, context) => {
      return Point.registerPoint(snapshot.val(), context);
    });
