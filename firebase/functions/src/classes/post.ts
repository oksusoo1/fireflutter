import * as admin from "firebase-admin";
import * as dayjs from "dayjs";
import * as dayOfYear from "dayjs/plugin/dayOfYear";
import * as weekOfYear from "dayjs/plugin/weekOfYear";

dayjs.extend(dayOfYear);
dayjs.extend(weekOfYear);

import { CommentDocument, PostDocument } from "../interfaces/forum.interface";

import { Ref } from "./ref";
import { ERROR_EMPTY_CATEGORY, ERROR_EMPTY_UID } from "../defines";
import { Messaging } from "./messaging";

export class Post {
  /**
   *
   * @param data post doc data to be created
   * @returns post doc data after create. Note that, it will contain post id.
   */
  static async create(data: any): Promise<PostDocument | null> {
    // check up
    if (!data.uid) throw ERROR_EMPTY_UID;
    if (!data.category) throw ERROR_EMPTY_CATEGORY;

    // get all the data from client.
    const doc: { [key: string]: any } = data as any;

    delete doc.password;

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
      return new PostDocument().fromDocument(snapshot.data(), ref.id);
    } else {
      return null;
    }
  }

  static async get(id: string): Promise<null | PostDocument> {
    const snapshot = await Ref.postDoc(id).get();
    if (snapshot.exists) {
      // return snapshot.data() as PostDocument;
      const data = snapshot.data();
      if (data) return new PostDocument().fromDocument(data, id);
    }
    return null;
  }

  static async sendMessageOnPostCreate(data: PostDocument) {
    const category = data.category;
    const payload = Messaging.topicPayload("posts_" + category, {
      title: data.title ? data.title : "",
      body: data.content ? data.content : "",
      postId: data.id,
      type: "post",
      uid: data.uid,
    });
    return admin.messaging().send(payload);
  }

  static async sendMessageOnCommentCreate(data: CommentDocument) {
    const post = await this.get(data.id);
    if (!post) return;

    const messageData: any = {
      title: "New Comment: ",
      body: post.content,
      postId: data.postId,
      type: "post",
      uid: data.uid,
    };
    console.log(messageData);

    const topic = "comments_" + post.category;

    // send push notification to topics
    // const sendToTopicRes = await admin
    //   .messaging()
    //   .send(Messaging.topicPayload(topic, messageData));
    // console.log(sendToTopicRes);

    // get comment ancestors
    const ancestorsUid = await Post.getCommentAncestors(data.id, data.uid);
    console.log(ancestorsUid);

    // add the post uid if the comment author is not the post author
    if (post.uid != data.uid && !ancestorsUid.includes(post.uid)) {
      ancestorsUid.push(post.uid);
    }

    // Don't send the same message twice to topic subscribers and comment notifyees.
    const userUids = await Messaging.getCommentNotifyeeWithoutTopicSubscriber(
        ancestorsUid.join(","),
        topic
    );
    console.log(userUids);
    // get users tokens
    const tokens = await Messaging.getTokensFromUids(userUids.join(","));
    console.log(tokens);

    // const sendToTokenRes = await Messaging.sendingMessageToTokens(
    //   tokens,
    //   Messaging.preMessagePayload(messageData)
    // );
    // return {
    //   // topicResponse: sendToTopicRes,
    //   tokenResponse: sendToTokenRes,
    // };
  }

  // get comment ancestor by getting parent comment until it reach the root comment
  // return the uids of the author
  static async getCommentAncestors(id: string, authorUid: string) {
    let comment = new CommentDocument().fromDocument(await Ref.commentDoc(id).get(), id);
    const uids = [];
    while (comment.postId != comment.parentId) {
      const com = await Ref.commentDoc(comment.parentId).get();
      if (!com.exists) continue;
      comment = new CommentDocument().fromDocument(com, comment.parentId);
      if (comment.uid == authorUid) continue; // skip the author's uid.
      uids.push(comment.uid);
    }
    return uids.filter((v, i, a) => a.indexOf(v) === i); // remove duplicate
  }
}
