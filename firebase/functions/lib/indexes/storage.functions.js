"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateFileParentIdForComment = exports.updateFileParentIdForPost = void 0;
const functions = require("firebase-functions");
const storage_1 = require("../classes/storage");
// When a post or a comment had created with 'files', put the doc id on file meta.
exports.updateFileParentIdForPost = functions
    .region("us-central1", "asia-northeast3")
    .firestore.document("/posts/{postId}")
    .onWrite((change, context) => {
    return storage_1.Storage.updateFileParentId(context.params.postId, change.after.data());
});
exports.updateFileParentIdForComment = functions
    .region("us-central1", "asia-northeast3")
    .firestore.document("/comments/{commentId}")
    .onWrite((change, context) => {
    return storage_1.Storage.updateFileParentId(context.params.commentId, change.after.data());
});
//# sourceMappingURL=storage.functions.js.map