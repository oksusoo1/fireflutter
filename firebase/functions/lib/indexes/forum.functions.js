"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendMessageOnCommentCreate = exports.sendMessageOnPostCreate = exports.authTest = exports.inputTest = exports.postCreate = void 0;
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
const functions = require("firebase-functions");
const post_1 = require("../classes/post");
const ready_1 = require("../ready");
const forum_interface_1 = require("../interfaces/forum.interface");
// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript
exports.postCreate = functions.region("asia-northeast3").https.onRequest((req, res) => {
    ready_1.ready({ req, res, auth: true }, async (data) => {
        res.status(200).send(await post_1.Post.create(data));
    });
});
exports.inputTest = functions.region("asia-northeast3").https.onRequest((req, res) => {
    ready_1.ready({ req, res, auth: false }, async (data) => {
        res.status(200).send(data);
    });
});
exports.authTest = functions.region("asia-northeast3").https.onRequest((req, res) => {
    ready_1.ready({ req, res, auth: true }, async (data) => {
        console.log("data; ", data);
        res.status(200).send(data);
    });
});
exports.sendMessageOnPostCreate = functions
    .region("asia-northeast3")
    .firestore.document("/posts/{postId}")
    .onCreate((snapshot, context) => {
    return post_1.Post.sendMessageOnPostCreate(new forum_interface_1.PostDocument().fromDocument(snapshot.data(), context.params.postId));
});
exports.sendMessageOnCommentCreate = functions
    .region("asia-northeast3")
    .firestore.document("/comments/{commentId}")
    .onCreate((snapshot, context) => {
    return post_1.Post.sendMessageOnCommentCreate(new forum_interface_1.CommentDocument().fromDocument(snapshot.data(), context.params.commentId));
});
//# sourceMappingURL=forum.functions.js.map