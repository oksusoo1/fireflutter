import * as functions from "firebase-functions";
import { Meilisearch, PostDocument } from "../classes/meilisearch";

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
  .firestore.document("/posts/{postId}")
  .onCreate((snapshot, context) => {
    return Meilisearch.indexPostCreate(snapshot.data() as PostDocument, context);
  });

export const onPostCreateUpdate = functions
  .region("asia-northeast3")
  .firestore.document("/posts/{postId}")
  .onUpdate((change, context) => {
    return Meilisearch.indexPostUpdate(change as any, context);
  });
