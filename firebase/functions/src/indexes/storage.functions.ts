import * as functions from "firebase-functions";
import { Storage } from "../classes/storage";

// When a post or a comment had created with 'files', put the doc id on file meta.
export const updateFileParentIdForPost = functions
    .region("asia-northeast3")
    .firestore.document("/posts/{postId}")
    .onWrite((change, context) => {
      return Storage.updateFileParentId(context.params.postId, change.after.data());
    });

export const updateFileParentIdForComment = functions
    .region("asia-northeast3")
    .firestore.document("/comments/{commentId}")
    .onWrite((change, context) => {
      return Storage.updateFileParentId(context.params.commentId, change.after.data());
    });
