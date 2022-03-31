import * as functions from "firebase-functions";
import { Point } from "../library/point";

/**
 * Listens for a user sign in and do point event.
 * A doc will be created at /point/{uid}/signIn/{pushId}
 *
 * * Note that, it will also do 'register point event' if the user didn't have one (for any cases).
 *
 * @test How to test
 * % npm run shell
 * % pointEventSignIn({after: {lastLogin: 1234}}, {params: {uid: 'a'}})
 */
export const pointEventSignIn = functions
  .region("asia-northeast3")
  .database.ref("/users/{uid}/lastSignInAt")
  .onUpdate(async (change, context) => {
    await Point.signInPoint(change.after.val(), context);
    return Point.registerPoint(change.after.val(), context);
  });

/**
 * Listens for a new user to be register(created) at /users/:uid and do point event.
 * A doc will be created at /point/{uid}/register
 *
 * @test How to test
 * % npm run shell
 * % pointEventRegister({}, {params: {uid: 'a'}})
 */
export const pointEventRegister = functions
  .region("asia-northeast3")
  .database.ref("/users/{uid}")
  .onCreate((snapshot, context) => {
    return Point.registerPoint(snapshot.val(), context);
  });

/**
 * Listens for a user sign in and do point event.
 * A doc will be created at /point/{uid}/signIn/{pushId}
 *
 * @test How to test
 * % npm run shell
 * % pointEventPostCreate( {uid: 'a'}, {params: {postId: 'post-1'}} )
 */
export const pointEventPostCreate = functions
  .region("asia-northeast3")
  .firestore.document("/posts/{postId}")
  .onCreate((snapshot, context) => {
    return Point.postCreatePoint(snapshot.data(), context);
  });

export const onCommentCreatePoint = functions
  .region("asia-northeast3")
  .firestore.document("/comments/{commentId}")
  .onCreate((snapshot, context) => {
    return Point.commentCreatePoint(snapshot.data(), context);
  });
