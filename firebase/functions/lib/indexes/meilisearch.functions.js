"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteUserIndex = exports.updateUserIndex = exports.createUserIndex = exports.onCommentUpdateIndex = exports.onCommentCreateIndex = exports.onPostUpdateIndex = exports.onPostCreateIndex = void 0;
const functions = require("firebase-functions");
const meilisearch_1 = require("../classes/meilisearch");
/**
 * Indexes a post document when it is created.
 *
 * onPostCreateIndex({
 *  uid: 'user_ccc',
 *  category: 'discussion',
 *  title: 'I post on discussion',
 *  content: 'Discussion'
 * })
 *
 * @test how to run in shell
 * % npm run shell
 * > onPostCreateIndex({uid: 'a'}, {params: {postId: 'p-1'}});
 */
exports.onPostCreateIndex = functions
    .region("asia-northeast3")
    .firestore.document("/posts/{id}")
    .onCreate((snapshot, context) => {
    return meilisearch_1.Meilisearch.indexPostCreate(snapshot.data(), context);
});
exports.onPostUpdateIndex = functions
    .region("asia-northeast3")
    .firestore.document("/posts/{id}")
    .onUpdate((change, context) => {
    const afterData = change.after.data();
    if (afterData["deleted"]) {
        return meilisearch_1.Meilisearch.deleteIndexedPostDocument(context);
    }
    else {
        return meilisearch_1.Meilisearch.indexPostUpdate(change, context);
    }
});
exports.onCommentCreateIndex = functions
    .region("asia-northeast3")
    .firestore.document("/comments/{id}")
    .onCreate((snapshot, context) => {
    return meilisearch_1.Meilisearch.indexCommentCreate(snapshot.data(), context);
});
exports.onCommentUpdateIndex = functions
    .region("asia-northeast3")
    .firestore.document("/comments/{id}")
    .onUpdate((change, context) => {
    const afterData = change.after.data();
    if (afterData["deleted"]) {
        return meilisearch_1.Meilisearch.deleteIndexedCommentDocument(context);
    }
    else {
        return meilisearch_1.Meilisearch.indexCommentUpdate(change, context);
    }
});
/**
 * Indexes a user document whenever it is created (someone registered a new account).
 *
 * createUserIndex({
 *  uid: '...',
 *  ...
 * })
 */
exports.createUserIndex = functions.auth.user().onCreate((user) => {
    return meilisearch_1.Meilisearch.indexUserCreate(user);
});
/**
 * Updates a user document index.
 *
 * updateUserIndex({
 *   before: {},
 *   after: { firstName: '...'  }
 *  }, {
 *   params: { userId: '...' }
 * })
 */
exports.updateUserIndex = functions
    .region("asia-northeast3")
    .database.ref("/users/{uid}")
    .onUpdate((change, context) => {
    return meilisearch_1.Meilisearch.indexUserUpdate({
        before: change.before.val(),
        after: change.after.val(),
    }, context);
});
/**
 * Deletes indexing whenever a user document is deleted (user resignation).
 *
 * deleteUserIndex({
 *  uid: '...'
 * })
 */
exports.deleteUserIndex = functions.auth.user().onDelete((user) => {
    return meilisearch_1.Meilisearch.deleteIndexedUserDocument(user);
});
//# sourceMappingURL=meilisearch.functions.js.map