import * as admin from "firebase-admin";

export interface CategoryDocument {
  id?: string;
  createdAt?: number;
  updatedAt?: number;
  order?: number;
  title?: string;
  description?: string;
  backgroundColor?: string;
  foregroundColor?: string;
  categoryGroup?: string;
  point?: number;
}

/**
 * Post document class for multi purpose.
 *
 * This can be used as a type like below.
 *
 * ```ts
 * const post = res2.data as PostDocument;
 * ```
 */
export interface PostDocument {
  id?: string;
  uid: string;
  category: string;
  subcategory?: string;
  title?: string;
  content?: string;
  summary?: string;
  files?: string[];
  hasPhoto?: boolean;
  deleted?: boolean;
  noOfComments?: number;
  year?: number;
  month?: number;
  day?: number;
  dayOfYear?: number;
  week?: number;
  createdAt?: admin.firestore.FieldValue;
  updatedAt?: admin.firestore.FieldValue;
  point?: number;
  [key: string]: any;
}

/**
 * A multi-purpose comment document interface representing the comment document of firebase.
 *
 */
export interface CommentDocument {
  id: string;
  uid: string;
  postId: string;
  parentId: string;
  content: string;
  files: string[];
  hasPhoto: boolean;
  deleted: boolean;
  createdAt?: admin.firestore.FieldValue;
  updatedAt?: admin.firestore.FieldValue;
  point: number;
}

/**
 * For passing parameters only on creating comment.
 */
export interface CommentCreateParams {
  uid: string;
  postId: string;
  parentId?: string;
  content?: string;
  files?: string[];
}

/**
 * To create a comment, it needs the complete data model.
 * Use this to create a comment.
 */
export interface CommentCreateRequirements {
  uid: string;
  postId: string;
  parentId: string;
  content: string;
  files: string[];
  hasPhoto: boolean;
  deleted: false;
  createdAt: admin.firestore.FieldValue;
  updatedAt: admin.firestore.FieldValue;
}
