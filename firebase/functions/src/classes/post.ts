import * as admin from "firebase-admin";
import * as dayjs from "dayjs";
import * as dayOfYear from "dayjs/plugin/dayOfYear";
import * as weekOfYear from "dayjs/plugin/weekOfYear";

dayjs.extend(dayOfYear);
dayjs.extend(weekOfYear);

import { PostDocument } from "../interfaces/forum.interface";

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
    if (!data.uid) throw ERROR_EMPTY_UID;
    if (!data.category) throw ERROR_EMPTY_CATEGORY;
    const doc: { [key: string]: any } = data as any;

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

    const ref = await Ref.postCol.add(doc);
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

  static async sendMessageOnPostCreate(data: PostDocument, context: any) {
    const category = data.category;
    const payload = Messaging.topicPayload("posts_" + category, {
      title: data.title ? data.title : "",
      body: data.content ? data.content : "",
      postId: context.params.postId,
      type: "post",
      uid: data.uid,
    });
    return admin.messaging().send(payload);
  }
}
