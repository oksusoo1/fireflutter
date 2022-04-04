"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.pointHistory = exports.pointEventCommentCreate = exports.pointEventPostCreate = exports.pointEventRegister = exports.pointEventSignIn = void 0;
const functions = require("firebase-functions");
const point_1 = require("../classes/point");
const ready_1 = require("../ready");
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
exports.pointEventSignIn = functions
    .region("asia-northeast3")
    .database.ref("/users/{uid}/lastSignInAt")
    .onUpdate(async (change, context) => {
    await point_1.Point.signInPoint(change.after.val(), context);
    return point_1.Point.registerPoint(change.after.val(), context);
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
    return point_1.Point.registerPoint(snapshot.val(), context);
});
/**
 * Listens for a user sign in and do point event.
 * A doc will be created at /point/{uid}/signIn/{pushId}
 *
 * @test How to test
 * % npm run shell
 * % pointEventPostCreate( {uid: 'a'}, {params: {postId: 'post-1'}} )
 */
exports.pointEventPostCreate = functions
    .region("asia-northeast3")
    .firestore.document("/posts/{postId}")
    .onCreate((snapshot, context) => {
    return point_1.Point.postCreatePoint(snapshot.data(), context);
});
exports.pointEventCommentCreate = functions
    .region("asia-northeast3")
    .firestore.document("/comments/{commentId}")
    .onCreate((snapshot, context) => {
    return point_1.Point.commentCreatePoint(snapshot.data(), context);
});
exports.pointHistory = functions.region("asia-northeast3").https.onRequest((req, res) => {
    ready_1.ready({ req, res, auth: true }, async (data) => {
        res.status(200).send(await point_1.Point.history(data));
    });
});
//# sourceMappingURL=point.functions.js.map