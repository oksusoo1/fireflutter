import * as admin from "firebase-admin";

export interface CategoryDocument {
  id?: string;
  timestamp?: number;
  order: number;
  title: string;
  description: string;
  backgroundColor?: string;
  foregroundColor?: string;
}

export interface ForumDocument {
  id?: string;
  uid: string;
  content?: string;
  files?: string | string[];
  createdAt?: number;
  updatedAt?: number;
}

export interface PostDocument extends ForumDocument {
  title: string;
  category: string;
  noOfComments?: number;
  deleted?: "Y" | "N";
}
export interface CommentDocument extends ForumDocument {
  postId: string;
  parentId: string;
}

export interface PostCreate {
  uid: string;
  category: string;
  subcategory?: string;
  title?: string;
  content?: string;
  summary?: string;
  files?: string;
  hasPhoto: boolean;
  deleted: false;
  noOfComment: 0;
  year: number;
  month: number;
  day: number;
  dayOfYear: number;
  week: number;
  createdAt: admin.firestore.FieldValue;
  updatedAt: admin.firestore.FieldValue;
}
