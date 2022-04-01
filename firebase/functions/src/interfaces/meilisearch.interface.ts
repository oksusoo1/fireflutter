export interface MeiliSearchForumDocument {
  id: string;
  uid: string;
  files?: string;
  content?: string;
  createdAt?: number;
  updatedAt: number;
}
export interface MeiliSearchPostDocument extends MeiliSearchForumDocument {
  category: string;
  title?: string;
  noOfComments?: number;
  /// present only on create
  /// this cannot be true at anytime since it will not be changed,
  /// and deleted documents will be will be literally get deleted.
  deleted: false;
}

export interface MeiliSearchCommentDocument extends MeiliSearchForumDocument {
  postId: string;
  parentId: string;
}
