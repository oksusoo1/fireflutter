import * as admin from "firebase-admin";

import { Ref } from "./ref";
import { ERROR_EMPTY_UID } from "../defines";
import {
  CommentCreateParams,
  CommentCreateRequirements,
  CommentDocument,
} from "../interfaces/forum.interface";

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
