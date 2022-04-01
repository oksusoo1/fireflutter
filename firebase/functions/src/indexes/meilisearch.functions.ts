import * as functions from "firebase-functions";
import { Meilisearch } from "../classes/meilisearch";
import { PostDocument } from "../interfaces/forum.interface";

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
    const afterData = change.after.data();
    if (afterData["deleted"]) {
      return Meilisearch.deleteIndexedPostDocument(context);
    } else {
      return Meilisearch.indexPostUpdate(change as any, context);
    }
  });
