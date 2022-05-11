/**
 * if [content] is 'Y', then it will return content. By default, it is 'Y'.
 * if [author] is 'Y', then it will return author's name, level, photoUrl. By default, it is 'Y'.
 */
export interface PostListOptions {
  category?: string;
  limit?: string;
  startAfter?: string;
  content?: "Y" | "N";
  author?: "Y" | "N";
}

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
  createdAt?: number;
  updatedAt?: number;
  point?: number;
  [key: string]: any;
}

/**
 * A multi-purpose comment document interface representing the comment document of firebase.
 *
 */
export interface CommentDocument {
  id?: string;
  uid: string;
  postId: string;
  parentId: string;
  content: string;
  files: string[];
  hasPhoto: boolean;
  deleted: boolean;
  createdAt?: number;
  updatedAt?: number;
  point: number;
  [key: string]: any;
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
  createdAt: number;
  updatedAt: number;
}
