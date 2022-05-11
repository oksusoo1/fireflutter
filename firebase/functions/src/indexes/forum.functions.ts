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
import { ready } from "../ready";
import { Post } from "../classes/post";
import { Comment } from "../classes/comment";
import { CommentDocument, PostDocument } from "../interfaces/forum.interface";
import { Report } from "../classes/report";

export const postList = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest((req, res) => {
    ready({ req, res }, async (data) => {
      res.status(200).send(await Post.list(data));
    });
  });

export const postView = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest((req, res) => {
    ready({ req, res }, async (data) => {
      res.status(200).send(await Post.view(data));
    });
  });

export const postCreate = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest((req, res) => {
    ready({ req, res, auth: true }, async (data) => {
      res.status(200).send(await Post.create(data));
    });
  });

export const postUpdate = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest((req, res) => {
    ready({ req, res, auth: true }, async (data) => {
      res.status(200).send(await Post.update(data));
    });
  });

export const postDelete = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest((req, res) => {
    ready({ req, res, auth: true }, async (data) => {
      res.status(200).send(await Post.delete(data));
    });
  });

export const commentCreate = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest((req, res) => {
    ready({ req, res, auth: true }, async (data) => {
      res.status(200).send(await Comment.create(data));
    });
  });

export const commentUpdate = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest((req, res) => {
    ready({ req, res, auth: true }, async (data) => {
      res.status(200).send(await Comment.update(data));
    });
  });

export const commentDelete = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest((req, res) => {
    ready({ req, res, auth: true }, async (data) => {
      res.status(200).send(await Comment.delete(data));
    });
  });

export const sendMessageOnPostCreate = functions
  .region("asia-northeast3")
  .firestore.document("/posts/{postId}")
  .onCreate((snapshot, context) => {
    return Post.sendMessageOnCreate(snapshot.data() as PostDocument, context.params.postId);
  });

export const sendMessageOnCommentCreate = functions
  .region("asia-northeast3")
  .firestore.document("/comments/{commentId}")
  .onCreate((snapshot, context) => {
    return Comment.sendMessageOnCreate(
      snapshot.data() as CommentDocument,
      context.params.commentId
    );
  });

export const report = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest((req, res) => {
    ready({ req, res, auth: true }, async (data) => {
      res.status(200).send(await Report.create(data));
    });
  });
