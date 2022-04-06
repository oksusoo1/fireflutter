import * as admin from "firebase-admin";
import * as dayjs from "dayjs";
import * as dayOfYear from "dayjs/plugin/dayOfYear";
import * as weekOfYear from "dayjs/plugin/weekOfYear";

dayjs.extend(dayOfYear);
dayjs.extend(weekOfYear);

import { CommentDocument, PostDocument } from "../interfaces/forum.interface";

import { Ref } from "./ref";
import {
  ERROR_ALREADY_DELETED,
  ERROR_CREATE_FAILED,
  ERROR_EMPTY_CATEGORY,
  ERROR_EMPTY_ID,
  ERROR_EMPTY_UID,
  ERROR_NOT_YOUR_POST,
  ERROR_POST_NOT_EXIST,
  ERROR_UPDATE_FAILED,
} from "../defines";
import { Messaging } from "./messaging";
import { OnCommentCreateResponse } from "../interfaces/messaging.interface";
import { Storage } from "./storage";

export class Post {
  /**
   *
   * @see README.md for details.
   * @param data post doc data to be created
   * @returns
   * - post doc as in PostDocument interface after create. Note that, it will contain post id.
   * - Or it will throw an exception on failing post creation.
   * @note exception will be thrown on error.
   */
  static async create(data: any): Promise<PostDocument> {
    // check up
    if (!data.uid) throw ERROR_EMPTY_UID;
    if (!data.category) throw ERROR_EMPTY_CATEGORY;

    // get all the data from client.
    const doc: { [key: string]: any } = data as any;

    // default data
    doc.hasPhoto = !!doc.files;
    doc.deleted = false;
    doc.noOfComments = 0;

    doc.year = dayjs().year();
    doc.month = dayjs().month() + 1;
    doc.day = dayjs().date();
    doc.dayOfYear = dayjs().dayOfYear();
    doc.week = dayjs().week();
    doc.createdAt = admin.firestore.FieldValue.serverTimestamp();
    doc.updatedAt = admin.firestore.FieldValue.serverTimestamp();

    // create post
    const ref = await Ref.postCol.add(doc);

    // return the document object of newly created post.
    const snapshot = await ref.get();
    if (snapshot.exists) {
      const postData = snapshot.data() as PostDocument;
      postData.id = ref.id;
      return postData;
    } else {
      throw ERROR_CREATE_FAILED;
    }
  }

  /**
   * Updates a post
   * @param data data to update the post
   * - data.id as post id is required.
   * - data.uid as post owner's uid is required.
   * @returns the post as PostDocument
   *
   * @note it throws exceptions on error.
   */
  static async update(data: any): Promise<PostDocument> {
    if (!data.id) throw ERROR_EMPTY_ID;
    const post = await this.get(data.id);
    if (post === null) throw ERROR_POST_NOT_EXIST;
    if (post.uid !== data.uid) throw ERROR_NOT_YOUR_POST;

    const id = data.id;
    delete data.id;
    data.updatedAt = admin.firestore.FieldValue.serverTimestamp();
    if (data.files && data.files.length) {
      data.hasPhoto = true;
    } else {
      data.hasPhoto = false;
    }
    await Ref.postDoc(id).update(data);
    const updated = await this.get(id);
    if (updated === null) throw ERROR_UPDATE_FAILED;
    return updated;
  }

  static async delete(data: { id: string; uid: string }): Promise<string> {
    const id = data.id;
    // 1. get the post.
    const post = await this.get(id);

    // 2. if it's null(not exists), throw ERROR_POST_NOT_EXITS,
    if (post === null) throw ERROR_POST_NOT_EXIST;

    // 3. check uid and if it's not the same of the document, throw ERROR_NOT_YOUR_POST;
    if (post.uid !== data.uid) throw ERROR_NOT_YOUR_POST;

    // 4. if the post had been marked as deleted, then throw ERROR_ALREADY_DELETED.
    if (post.deleted && post.deleted === true) throw ERROR_ALREADY_DELETED;

    // 5. if post has files, delete files from firebase storage.
    if (post.files?.length) {
      for (const url in post.files) {
        await Storage.deleteFileFromUrl(url);
      }
    }

    const postRef = Ref.postDoc(id);
    // 6.A if there is no comment, then delete the post.
    if (!post.noOfComments) {
      await postRef.delete();
      return id;
    }
    // 6.B or if there is a comment, then mark it as deleted. (deleted=true)
    else {
      post.title = "";
      post.content = "";
      post.deleted = true;
      await postRef.update(post);
    }

    return id;
  }
  /**
   * Returns a post as PostDocument or null if the post does not exists.
   * @param id post id
   * @returns post document or null if the post does not exitss.
   */
  static async get(id: string): Promise<PostDocument | null> {
    const snapshot = await Ref.postDoc(id).get();
    if (snapshot.exists) {
      // return snapshot.data() as PostDocument;
      const data = snapshot.data();
      if (data) {
        data.id = id;
        return data as PostDocument;
      }
    }
    return null;
  }

  static async sendMessageOnPostCreate(data: PostDocument, id: string) {
    const category = data.category;
    const payload = Messaging.topicPayload("posts_" + category, {
      title: data.title ?? "",
      body: data.content ?? "",
      postId: id,
      type: "post",
      uid: data.uid,
    });
    return admin.messaging().send(payload);
  }

  static async sendMessageOnCommentCreate(data: CommentDocument, id: string): Promise<OnCommentCreateResponse | null> {
    const post = await this.get(data.postId);
    if (!post) return null;

    const messageData: any = {
      title: "New Comment: ",
      body: post.content,
      postId: data.postId,
      type: "post",
      uid: data.uid,
    };

    // console.log(messageData);
    const topic = "comments_" + post.category;

    // send push notification to topics
    const sendToTopicRes = await admin.messaging().send(Messaging.topicPayload(topic, messageData));

    // get comment ancestors
    const ancestorsUid = await Post.getCommentAncestors(id, data.uid);

    // add the post uid if the comment author is not the post author
    if (post.uid != data.uid && !ancestorsUid.includes(post.uid)) {
      ancestorsUid.push(post.uid);
    }

    // Don't send the same message twice to topic subscribers and comment notifyees.
    const userUids = await Messaging.getCommentNotifyeeWithoutTopicSubscriber(ancestorsUid.join(","), topic);

    // get users tokens
    const tokens = await Messaging.getTokensFromUids(userUids.join(","));

    const sendToTokenRes = await Messaging.sendingMessageToTokens(tokens, Messaging.preMessagePayload(messageData));
    return {
      topicResponse: sendToTopicRes,
      tokenResponse: sendToTokenRes,
    };
  }

  // get comment ancestor by getting parent comment until it reach the root comment
  // return the uids of the author
  static async getCommentAncestors(id: string, authorUid: string) {
    const c = await Ref.commentDoc(id).get();
    let comment = c.data() as CommentDocument;
    const uids = [];
    while (comment.postId != comment.parentId) {
      const com = await Ref.commentDoc(comment.parentId).get();
      if (!com.exists) continue;
      comment = com.data() as CommentDocument;
      if (comment.uid == authorUid) continue; // skip the author's uid.
      uids.push(comment.uid);
    }
    return uids.filter((v, i, a) => a.indexOf(v) === i); // remove duplicate
  }
}
