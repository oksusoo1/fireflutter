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
import * as functions from "firebase-functions";
import { Post } from "../classes/post";
import { cors } from "../cors";
import { PostDocument } from "../interfaces/forum.interface";

// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript

export const postCreate = functions.region("asia-northeast3").https.onRequest((req, res) => {
  cors(req, res, async () => {
    console.log(req.query);
    // @todo - authentication here.
    res.status(200).send(await Post.create(req.query as any));
  });
});

export const sendMessageOnPostCreate = functions
  .region("asia-northeast3")
  .firestore.document("/posts/{postId}")
  .onCreate((snapshot, context) => {
    return Post.sendMessageOnPostCreate(snapshot.data() as PostDocument, context);
  });
