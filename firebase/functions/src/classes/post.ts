import * as admin from "firebase-admin";
import * as dayjs from "dayjs";
import * as dayOfYear from "dayjs/plugin/dayOfYear";
import * as weekOfYear from "dayjs/plugin/weekOfYear";

dayjs.extend(dayOfYear);
dayjs.extend(weekOfYear);

import { PostCreate, PostDocument } from "../interfaces/forum.interface";
import { Ref } from "./ref";
import { ERROR_EMPTY_CATEGORY, ERROR_EMPTY_UID } from "../defines";
import { Messaging } from "./messaging";

export class Post {
  /**
   *
   * @param data post doc data to be created
   * @returns post doc data after create. Note that, it will contain post id.
   */
  static async create(data: PostCreate): Promise<PostDocument | null> {
    if (!data.uid) throw ERROR_EMPTY_UID;
    if (!data.category) throw ERROR_EMPTY_CATEGORY;
    const doc: PostCreate = {
      uid: data.uid,
      category: data.category,
      subcategory: data.subcategory,
      title: data.title,
      content: data.content,
      summary: data.summary,
      files: data.files,
      hasPhoto: !!data.files,
      deleted: false,
      noOfComment: 0,
      year: dayjs().year(),
      month: dayjs().month() + 1,
      day: dayjs().date(),
      dayOfYear: dayjs().dayOfYear(),
      week: dayjs().week(),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    const ref = await Ref.postCol.add(doc);
    const snapshot = await ref.get();
    if (snapshot.exists) {
      const docData = snapshot.data()! as PostDocument;
      docData.id = ref.id;
      return docData;
    } else {
      return null;
    }
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
