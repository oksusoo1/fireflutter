import * as functions from "firebase-functions";
import { Meilisearch } from "../classes/meilisearch";
import { CommentDocument, PostDocument } from "../interfaces/forum.interface";
import { UserDocument } from "../interfaces/user.interface";

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
 *
 */
export const onPostCreateIndex = functions
    .region("asia-northeast3")
    .firestore.document("/posts/{id}")
    .onCreate((snapshot, context) => {
      return Meilisearch.indexPostCreate(snapshot.data() as PostDocument, context);
    });

export const onPostUpdateIndex = functions
    .region("asia-northeast3")
    .firestore.document("/posts/{id}")
    .onUpdate((change, context) => {
      const beforeData = change.before.data();
      const afterData = change.after.data();
      if (afterData["deleted"]) {
        return Meilisearch.deleteIndexedPostDocument(context);
      } else {
        return Meilisearch.indexPostUpdate(
        {
          before: beforeData,
          after: afterData,
        } as any,
        context
        );
      }
    });

/**
 * @note
 * on flutter app:
 *  - Posts without a comment will be deleted literally. so it comes here.
 *  - But, if it have a comment, it will simply update the field `deleted` to true.
 *    - see @onPostUpdateIndex
 */
export const onPostDeleteIndex = functions
    .region("asia-northeast3")
    .firestore.document("/posts/{id}")
    .onDelete((_snapshot, context) => {
      return Meilisearch.deleteIndexedPostDocument(context);
    });

export const onCommentCreateIndex = functions
    .region("asia-northeast3")
    .firestore.document("/comments/{id}")
    .onCreate((snapshot, context) => {
      return Meilisearch.indexCommentCreate(snapshot.data() as CommentDocument, context);
    });

export const onCommentUpdateIndex = functions
    .region("asia-northeast3")
    .firestore.document("/comments/{id}")
    .onUpdate((change, context) => {
      const beforeData = change.before.data();
      const afterData = change.after.data();
      if (afterData["deleted"]) {
        return Meilisearch.deleteIndexedCommentDocument(context);
      } else {
        return Meilisearch.indexCommentUpdate(
        {
          before: beforeData,
          after: afterData,
        } as any,
        context
        );
      }
    });

// export const onCommentDeleteIndex = functions
//     .region("asia-northeast3")
//     .firestore.document("/posts/{id}")
//     .onDelete((_snapshot, context) => {
//       return Meilisearch.deleteIndexedCommentDocument(context);
//     });

/**
 * Indexes a user document whenever it is created (someone registered a new account).
 *
 * createUserIndex({
 *  uid: '...',
 *  ...
 * })
 */
export const createUserIndex = functions.auth.user().onCreate((user) => {
  return Meilisearch.indexUserCreate(user);
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
export const updateUserIndex = functions
    .region("asia-northeast3")
    .database.ref("/users/{uid}")
    .onUpdate((change, context) => {
      return Meilisearch.indexUserUpdate(
          {
            before: change.before.val() as UserDocument,
            after: change.after.val() as UserDocument,
          },
          context
      );
    });

/**
 * Deletes indexing whenever a user document is deleted (user resignation).
 *
 * deleteUserIndex({
 *  uid: '...'
 * })
 */
export const deleteUserIndex = functions.auth.user().onDelete((user) => {
  return Meilisearch.deleteIndexedUserDocument(user);
});
