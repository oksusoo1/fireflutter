import { Ref } from "./ref";
import { Utils } from "./utils";
import { CommentDocument, PostDocument } from "../interfaces/forum.interface";
import { MeiliSearch as Meili, SearchParams, SearchResponse } from "meilisearch";
import { EventContext } from "firebase-functions/v1";
import { UserRecord } from "firebase-functions/v1/auth";
import { UserDocument } from "../interfaces/user.interface";

/**
 * TODO: Test
 *
 * - indexUserCreate
 * - indexUserUpdate
 * - deleteIndexedUserDocument
 */
export class Meilisearch {
  static excludedCategories = ["quiz"];

  static client = new Meili({
    host: "http://wonderfulkorea.kr:7700",
  });

  /**
   * Indexes document under [posts-and-comments] index.
   * @param data data to be index
   * @return Promise<any>
   */
  static indexForumDocument(data: any): Promise<any> {
    return this.client.index("posts-and-comments").addDocuments([data]);
  }

  /**
   * Deletes meilisearch document indexing from [posts-and-comments] index.
   *
   * @param context Event context
   * @return Promise
   */
  static deleteIndexedForumDocument(context: EventContext) {
    return this.client.index("posts-and-comments").deleteDocument(context.params.id);
  }

  /**
   * Creates a post document index.
   *
   * @param data post data to index
   * @param context Event context
   * @return Promise
   */
  static async indexPostCreate(data: PostDocument, context: EventContext) {
    if (this.excludedCategories.includes(data.category)) return null;

    const _data = {
      id: context.params.id,
      uid: data.uid,
      title: data.title ?? "",
      category: data.category,
      content: Utils.removeHtmlTags(data.content) ?? "",
      files: data.files ? data.files.join(",") : "",
      noOfComments: data.noOfComments ?? 0,
      deleted: false,
      createdAt: Utils.getTimestamp(),
      updatedAt: Utils.getTimestamp(),
    };

    const promises = [];

    promises.push(this.client.index("posts").addDocuments([_data]));
    // promises.push(axios.post("http://wonderfulkorea.kr:7700/indexes/posts/documents", _data));
    promises.push(this.indexForumDocument(_data));

    return Promise.all(promises);
  }

  /**
   * Update a post document index.
   *
   * @param data post data to index
   * @param context Event context
   * @return Promise
   *
   * @test tests/meilisearch/post-update.spect.ts
   */
  static async indexPostUpdate(
    data: { before: PostDocument; after: PostDocument },
    context: EventContext
  ): Promise<any> {
    if (this.excludedCategories.includes(data.after.category)) return null;
    if (data.before.title === data.after.title && data.before.content === data.after.content) {
      return null;
    }

    const after = data.after;

    const _data = {
      id: context.params.id,
      uid: after.uid,
      category: after.category,
      title: after.title ?? "",
      content: Utils.removeHtmlTags(after.content),
      files: after.files ? after.files.join(",") : "",
      noOfComments: after.noOfComments,
      deleted: false,
      updatedAt: Utils.getTimestamp(),
    };

    const promises = [];

    promises.push(this.client.index("posts").updateDocuments([_data]));
    promises.push(this.indexForumDocument(_data));

    return Promise.all(promises);
  }

  /**
   * Deletes indexed post document.
   *
   * @param context Post ID of the document to be deleted.
   * @return Promise
   */
  static async deleteIndexedPostDocument(context: EventContext) {
    const promises = [];
    promises.push(this.client.index("posts").deleteDocument(context.params.id));
    promises.push(this.deleteIndexedForumDocument(context));
    return Promise.all(promises);
  }

  /**
   * Creates a comment document index.
   *
   * @param data Document data
   * @param context Event context
   * @return Promise
   */
  static async indexCommentCreate(data: CommentDocument, context: EventContext) {
    const _data = {
      id: context.params.id,
      uid: data.uid,
      postId: data.postId,
      parentId: data.parentId,
      content: Utils.removeHtmlTags(data.content) ?? "",
      files: data.files ? data.files.join(",") : "",
      createdAt: Utils.getTimestamp(),
      updatedAt: Utils.getTimestamp(),
    };

    const promises = [];

    promises.push(this.client.index("comments").addDocuments([_data]));
    // promises.push(axios.post("http://wonderfulkorea.kr:7700/indexes/comments/documents", _data));
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
  static async indexCommentUpdate(data: { before: CommentDocument; after: CommentDocument }, context: EventContext) {
    if (data.before.content === data.after.content) return null;

    const after = data.after;

    const _data = {
      id: context.params.id,
      uid: after.uid,
      postId: after.postId,
      parentId: after.parentId,
      content: Utils.removeHtmlTags(after.content),
      files: after.files ? after.files.join(",") : "",
      updatedAt: Utils.getTimestamp(after.updatedAt),
    };

    const promises = [];

    promises.push(this.client.index("comments").updateDocuments([_data]));
    // promises.push(axios.post("http://wonderfulkorea.kr:7700/indexes/comments/documents", _data));
    promises.push(this.indexForumDocument(_data));

    return Promise.all(promises);
  }

  /**
   * Deletes indexed comment document.
   *
   * @param context Event context.
   * @return Promise
   */
  static async deleteIndexedCommentDocument(context: EventContext) {
    const promises = [];
    promises.push(this.client.index("comments").deleteDocument(context.params.id));
    // promises.push(axios.delete("http://wonderfulkorea.kr:7700/indexes/comments/documents/" + id));
    promises.push(this.deleteIndexedForumDocument(context));
    return Promise.all(promises);
  }

  /**
   * Indexes user data coming from create event of auth.
   *
   * @param {*} data User data to index. It must also contain the users id.
   * @return promise
   */
  static async indexUserCreate(data: UserRecord): Promise<any> {
    const _data = {
      id: data.uid,
      photoUrl: data.photoURL ?? "",
      registeredAt: Utils.getTimestamp(),
      updatedAt: Utils.getTimestamp(),
    };

    return this.client.index("users").addDocuments([_data]);
    // return axios.post("http://wonderfulkorea.kr:7700/indexes/users/documents", _data);
  }

  /**
   * Indexes user data coming from realtime database update.
   *
   * @param changes User data before and after.
   * @param context Event context.
   * @return promise
   */
  static async indexUserUpdate(
    changes: { before: UserDocument; after: UserDocument },
    context: EventContext
  ): Promise<any> {
    const before = changes.before;
    const after = changes.after;
    if (
      before.firstName === after.firstName &&
      before.middleName === after.middleName &&
      before.lastName === after.lastName
      /// Todo: add more ignore condition ? ...
    ) {
      return null;
    }

    const _data = {
      id: context.params.uid,
      photoUrl: after.photoUrl ?? "",
      gender: after.gender ?? "",
      firstName: after.firstName ?? "",
      middleName: after.middleName ?? "",
      lastName: after.lastName ?? "",
      birthday: after.birthday ?? 0,
      updatedAt: Utils.getTimestamp(),
    };

    return this.client.index("users").addDocuments([_data]);
    // return axios.post("http://wonderfulkorea.kr:7700/indexes/users/documents", _data);
  }

  /**
   * Deletes user related documents on realtime database and meilisearch indexing.
   *
   * @param user user data.
   * @return promise
   */
  static async deleteIndexedUserDocument(user: UserRecord) {
    const uid = user.uid;
    const promises = [];

    // Remove user data under it's uid from:
    // - 'users' and 'user-settings' realtime database,
    // - 'quiz-history' firestore database.
    promises.push(Ref.rdb.ref("users").child(uid).remove());
    promises.push(Ref.rdb.ref("user-settings").child(uid).remove());
    promises.push(Ref.db.collection("quiz-history").doc(uid).delete());
    promises.push(this.client.index("users").deleteDocument(uid));
    return Promise.all(promises);
  }

  /**
   * Search
   *
   * @param index
   * @param data search options
   * @returns Search result
   */
  static async search(
    index: string,
    data: { keyword?: string; searchOptions?: SearchParams }
  ): Promise<SearchResponse<Record<string, any>>> {
    return this.client.index(index).search(data.keyword, data.searchOptions);
  }
}
