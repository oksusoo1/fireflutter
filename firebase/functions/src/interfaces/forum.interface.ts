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
  id: string;
  uid: string;
  content: string;
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
