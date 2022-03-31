import axios from "axios";
import { Utils } from "./utils";

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
  deleted: "Y" | "N";
}

export interface CommentDocument extends ForumDocument {
  postId: string;
  parentId: string;
}

/**
 * TODO: Test
 * - indexPostDocument
 * - deleteIndexedPostDocument
 * - indexCommentDocument
 * - deleteIndexedCommentDocument
 * - indexUserDocument
 * - deleteIndexedUserDocument
 */
export class MeilisearchIndex {
  static meilisearchExcludedCategories = ["quiz"];

  /**
   * Index
   * @param data data to be index
   * @return Promise<any>
   */
  static indexForumDocument(data: PostDocument | CommentDocument): Promise<any> {
    return axios.post("http://wonderfulkorea.kr:7700/indexes/posts-and-comments/documents", data);
  }

  /**
   *
   * @param id document ID to delete
   * @return Promise
   */
  static deleteIndexedForumDocument(id: string) {
    return axios.delete("http://wonderfulkorea.kr:7700/indexes/posts-and-comments/documents/" + id);
  }

  /**
   * Creates or update a post document index.
   *
   * @param id post id
   * @param data post data to index
   * @return Promise
   */
  static async indexPostDocument(id: string, data: PostDocument) {
    let _files = "";
    if (data.files && data.files.length) {
      _files = typeof data.files == "string" ? data.files : data.files.join(",");
    }

    const _data: PostDocument = {
      id: id,
      uid: data.uid,
      title: data.title ?? "",
      category: data.category,
      content: data.content ?? "",
      files: _files,
      noOfComments: data.noOfComments ?? 0,
      deleted: data.deleted ? "Y" : "N",
      createdAt: Utils.getTimestamp(data.createdAt),
      updatedAt: Utils.getTimestamp(data.updatedAt),
    };

    const promises = [];

    promises.push(axios.post("https://wonderfulkorea.kr:4431/index.php?api=post/record", _data));

    if (!this.meilisearchExcludedCategories.includes(_data.category)) {
      _data.content = Utils.removeHtmlTags(_data.content);
      promises.push(axios.post("http://wonderfulkorea.kr:7700/indexes/posts/documents", _data));
      promises.push(this.indexForumDocument(_data));
    }

    return Promise.all(promises);
  }

  /**
   * Deletes indexed post document.
   *
   * @param id Post ID of the document to be deleted.
   * @return Promise
   */
  static async deleteIndexedPostDocument(id: string) {
    const promises = [];
    promises.push(
        axios.post("https://wonderfulkorea.kr:4431/index.php?api=post/delete", {
          id: id,
        })
    );
    promises.push(axios.delete("http://wonderfulkorea.kr:7700/indexes/posts/documents/" + id));
    promises.push(this.deleteIndexedForumDocument(id));
    return Promise.all(promises);
  }

  /**
   * Creates or update a comment document index.
   *
   * @param id Document ID
   * @param data Document data
   * @return Promise
   */
  static async indexCommentDocument(id: string, data: CommentDocument) {
    let _files = "";
    if (data.files && data.files.length) {
      _files = typeof data.files == "string" ? data.files : data.files.join(",");
    }

    const _data = {
      id: id,
      uid: data.uid,
      postId: data.postId,
      parentId: data.parentId,
      content: data.content,
      files: _files,
      createdAt: Utils.getTimestamp(data.createdAt),
      updatedAt: Utils.getTimestamp(data.updatedAt),
    };

    const promises = [];

    promises.push(axios.post("https://wonderfulkorea.kr:4431/index.php?api=post/record", _data));

    _data.content = Utils.removeHtmlTags(_data.content);
    promises.push(axios.post("http://wonderfulkorea.kr:7700/indexes/comments/documents", _data));
    promises.push(this.indexForumDocument(_data));

    return Promise.all(promises);
  }

  /**
   * Deletes indexed comment document.
   *
   * @param id Comment ID of the document to be deleted.
   * @return Promise
   */
  static async deleteIndexedCommentDocument(id: string) {
    const promises = [];
    promises.push(
        axios.post("https://wonderfulkorea.kr:4431/index.php?api=post/delete", {
          id: id,
        })
    );
    promises.push(axios.delete("http://wonderfulkorea.kr:7700/indexes/comments/documents/" + id));
    promises.push(this.deleteIndexedForumDocument(id));
    return Promise.all(promises);
  }

  /**
   * Creates or update a user document index.
   *
   * @param {*} uid user id.
   * @param {*} data user data to index.
   * @return promise
   */
  async indexUserDocument(uid: string, data: any = {}) {
    const _data = {
      id: uid,
      gender: data.gender ?? "",
      firstName: data.firstName ?? "",
      middleName: data.middleName ?? "",
      lastName: data.lastName ?? "",
      photoUrl: data.photoUrl ?? "",
      // registeredAt: data.registeredAt ?? 0,
      // updatedAt: data.updatedAt ?? 0,
    };
    return axios.post("http://wonderfulkorea.kr:7700/indexes/users/documents", _data);
  }

  /**
   * Deletes user related documents on realtime database and meilisearch indexing.
   *
   * @param {*} uid user id to delete.
   * @return promise
   */
  async deleteIndexedUserDocument(uid: string) {
    const promises = [];

    // Remove user data under it's uid from:
    // - 'users' and 'user-settings' realtime database,
    // - 'quiz-history' firestore database.
    // promises.push(rdb.ref("users").child(uid).remove());
    // promises.push(rdb.ref("user-settings").child(uid).remove());
    // promises.push(db.collection("quiz-history").doc(uid).delete());
    promises.push(axios.delete("http://wonderfulkorea.kr:7700/indexes/users/documents/" + uid));
    return Promise.all(promises);
  }

  // / FOR TESTING
  // / TODO: move this code somewhere else.
  static createTestPostDocument(data: {
    id: string;
    uid?: string;
    title?: string;
    content?: string;
  }): PostDocument {
    return {
      id: data.id,
      uid: data.uid ?? new Date().getTime().toString(),
      title: data.title ?? new Date().getTime().toString(),
      content: data.content ?? new Date().getTime().toString(),
      category: "test-cat",
      deleted: "N",
    };
  }
}
