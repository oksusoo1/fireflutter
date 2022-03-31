import axios from "axios";
import { Utils } from "./utils";
import { CommentDocument, PostDocument } from "../interfaces/forum.interface";

/**
 * TODO: Test
 * - indexPostDocument
 * - deleteIndexedPostDocument
 * - indexCommentDocument
 * - deleteIndexedCommentDocument
 * - indexUserDocument
 * - deleteIndexedUserDocument
 */
export class Meilisearch {
  static excludedCategories = ["quiz"];

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
   * Creates a post document index.
   *
   * @param data post data to index
   * @param context context
   * @return Promise
   */
  static async indexPostCreate(data: PostDocument, context: any) {
    if (this.excludedCategories.includes(data.category)) return null;

    const _data: PostDocument = {
      id: context.params.id,
      uid: data.uid,
      title: data.title ?? "",
      category: data.category,
      content: Utils.removeHtmlTags(data.content),
      files: Array.isArray(data.files) ? data.files.join(",") : data.files,
      noOfComments: data.noOfComments ?? 0,
      deleted: data.deleted ? "Y" : "N",
      createdAt: Utils.getTimestamp(data.createdAt),
      updatedAt: Utils.getTimestamp(data.updatedAt),
    };

    const promises = [];

    promises.push(axios.post("http://wonderfulkorea.kr:7700/indexes/posts/documents", _data));
    promises.push(this.indexForumDocument(_data));

    return Promise.all(promises);
  }

  /**
   * Update a post document index.
   *
   * @param data post data to index
   * @param context context
   * @return Promise
   */
  static async indexPostUpdate(data: { before: PostDocument; after: PostDocument }, context: any) {
    if (this.excludedCategories.includes(data.after.category)) return null;
    if (data.before.title === data.after.title && data.before.content === data.after.content) {
      return null;
    }

    const after = data.after;

    const _data: PostDocument = {
      id: context.params.id,
      uid: after.uid,
      title: after.title ?? "",
      category: after.category,
      content: Utils.removeHtmlTags(after.content),
      files: Array.isArray(after.files) ? after.files.join(",") : after.files,
      noOfComments: after.noOfComments ?? 0,
      deleted: after.deleted ? "Y" : "N",
      updatedAt: Utils.getTimestamp(after.updatedAt),
    };

    const promises = [];

    promises.push(axios.post("http://wonderfulkorea.kr:7700/indexes/posts/documents", _data));
    promises.push(this.indexForumDocument(_data));

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
   * Creates a comment document index.
   *
   * @param data Document data
   * @param context Event context
   * @return Promise
   */
  static async indexCommentCreate(data: CommentDocument, context: any) {
    const _data = {
      id: context.params.id,
      uid: data.uid,
      postId: data.postId,
      parentId: data.parentId,
      content: Utils.removeHtmlTags(data.content) ?? "",
      files: Array.isArray(data.files) ? data.files.join(",") : data.files,
      createdAt: Utils.getTimestamp(data.createdAt),
      updatedAt: Utils.getTimestamp(data.updatedAt),
    };

    const promises = [];

    promises.push(axios.post("http://wonderfulkorea.kr:7700/indexes/comments/documents", _data));
    promises.push(this.indexForumDocument(_data));

    return Promise.all(promises);
  }

  /**
   * Updates a comment document index.
   *
   * @param data Document data
   * @param context Event context
   * @return Promise
   */
  static async indexCommentUpdate(data: { before: CommentDocument; after: CommentDocument }, context: any) {
    if (data.before.content === data.after.content) return null;

    const after = data.after;

    const _data: CommentDocument = {
      id: context.params.id,
      uid: after.uid,
      postId: after.postId,
      parentId: after.parentId,
      content: Utils.removeHtmlTags(after.content),
      files: Array.isArray(after.files) ? after.files.join(",") : after.files,
      updatedAt: Utils.getTimestamp(after.updatedAt),
    };

    const promises = [];

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

  // FOR TESTING
  // TODO: move this code somewhere else.
  static createTestPostDocument(data: { id: string; uid?: string; title?: string; content?: string }): PostDocument {
    return {
      id: data.id,
      uid: data.uid ?? "test-uid",
      title: data.title ?? `${data.id} title`,
      content: data.content ?? `${data.id} content`,
      category: "test-cat",
    };
  }
}
