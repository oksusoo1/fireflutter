import * as admin from "firebase-admin";

import { Ref } from "./ref";
import {
  ERROR_COMMENT_NOT_EXISTS,
  ERROR_EMPTY_ID,
  ERROR_EMPTY_UID,
  ERROR_NOT_YOUR_COMMENT,
  ERROR_UPDATE_FAILED,
} from "../defines";
import { CommentCreateParams, CommentCreateRequirements, CommentDocument } from "../interfaces/forum.interface";

export class Comment {
  /**
   * Creates a comment
   *
   * @param data comment doc data to be created
   * @returns comment doc data after create. Note that, it will contain post id.
   */
  static async create(data: CommentCreateParams): Promise<CommentDocument | null> {
    if (!data.uid) throw ERROR_EMPTY_UID;
    const doc: CommentCreateRequirements = {
      uid: data.uid,
      postId: data.postId,
      parentId: data.parentId ?? "",
      content: data.content ?? "",
      files: data.files ?? [],
      hasPhoto: !!data.files,
      deleted: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    const ref = await Ref.commentCol.add(doc);
    const snapshot = await ref.get();
    if (snapshot.exists) {
      const comment = snapshot.data() as CommentDocument;
      comment.id = ref.id;
      return comment;
    } else {
      return null;
    }
  }

  /**
   * Updates a comment
   * 
   * @param data comment data to update with.
   * @returns updated comment doc data.
   */
  static async update(data: any): Promise<CommentDocument> {
    if (!data.id) throw ERROR_EMPTY_ID;
    if (!data.uid) throw ERROR_EMPTY_UID;

    const id = data.id;
    const comment = await this.get(id);
    if (comment === null) throw ERROR_COMMENT_NOT_EXISTS;
    if (comment!.uid !== data.uid) throw ERROR_NOT_YOUR_COMMENT;

    delete data.id;
    // updatedAt
    data.updatedAt = admin.firestore.FieldValue.serverTimestamp();

    // hasPhoto
    if (data.files && data.files.length) {
      data.hasPhoto = true;
    } else {
      data.hasPhoto = false;
    }

    await Ref.commentDoc(id).update(data);
    const updated = await this.get(id);
    if (updated === null) throw ERROR_UPDATE_FAILED;
    return updated;
  }

  static async get(id: string): Promise<null | CommentDocument> {
    const snapshot = await Ref.commentDoc(id).get();
    if (snapshot.exists) {
      const comment = snapshot.data() as CommentDocument;
      comment.id = id;
      return comment;
    }
    return null;
  }
}

