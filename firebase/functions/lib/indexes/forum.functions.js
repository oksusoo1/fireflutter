"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.report = exports.sendMessageOnCommentCreate = exports.sendMessageOnPostCreate = exports.commentDelete = exports.commentUpdate = exports.commentCreate = exports.postDelete = exports.postUpdate = exports.postCreate = void 0;
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
const ready_1 = require("../ready");
const post_1 = require("../classes/post");
const comment_1 = require("../classes/comment");
// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript
exports.postCreate = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest((req, res) => {
    ready_1.ready({ req, res, auth: true }, async (data) => {
        res.status(200).send(await post_1.Post.create(data));
    });
});
exports.postUpdate = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest((req, res) => {
    ready_1.ready({ req, res, auth: true }, async (data) => {
        res.status(200).send(await post_1.Post.update(data));
    });
});
exports.postDelete = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest((req, res) => {
    ready_1.ready({ req, res, auth: true }, async (data) => {
        res.status(200).send(await post_1.Post.delete(data));
    });
});
exports.commentCreate = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest((req, res) => {
    ready_1.ready({ req, res, auth: true }, async (data) => {
        res.status(200).send(await comment_1.Comment.create(data));
    });
});
exports.commentUpdate = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest((req, res) => {
    ready_1.ready({ req, res, auth: true }, async (data) => {
        res.status(200).send(await comment_1.Comment.update(data));
    });
});
exports.commentDelete = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest((req, res) => {
    ready_1.ready({ req, res, auth: true }, async (data) => {
        res.status(200).send(await comment_1.Comment.delete(data));
    });
});
exports.sendMessageOnPostCreate = functions
    .region("asia-northeast3")
    .firestore.document("/posts/{postId}")
    .onCreate((snapshot, context) => {
    return post_1.Post.sendMessageOnPostCreate(snapshot.data(), context.params.postId);
});
exports.sendMessageOnCommentCreate = functions
    .region("asia-northeast3")
    .firestore.document("/comments/{commentId}")
    .onCreate((snapshot, context) => {
    return post_1.Post.sendMessageOnCommentCreate(snapshot.data(), context.params.commentId);
});
exports.report = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest((req, res) => {
    ready_1.ready({ req, res, auth: true }, async (data) => {
        res.status(200).send(await comment_1.Comment.delete(data));
    });
});
//# sourceMappingURL=forum.functions.js.map