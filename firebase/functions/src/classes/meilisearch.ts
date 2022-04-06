import { Ref } from "./ref";
import { Utils } from "./utils";
import { CommentDocument, PostDocument } from "../interfaces/forum.interface";
import { MeiliSearch as Meili, SearchResponse } from "meilisearch";
import { EventContext } from "firebase-functions/v1";
import { UserRecord } from "firebase-functions/v1/auth";
import { UserDocument } from "../interfaces/user.interface";

export class Meilisearch {
  static excludedCategories = ["quiz"];

  static readonly USERS_INDEX = "users";
  static readonly FORUM_INDEX = "posts-and-comments";
  static readonly POSTS_INDEX = "posts";
  static readonly COMMENTS_INDEX = "comments";

  static readonly USER_SETTINGS = "user-settings";
  static readonly QUIZ_HISTORY = "quiz-history";

  static client = new Meili({
    host: "http://wonderfulkorea.kr:7700",
  });

  /**
   * Indexes document under [posts-and-comments] index.
   * @param data data to be index
   * @return Promise<any>
   */
  static indexForumDocument(data: any): Promise<any> {
    return this.client.index(this.FORUM_INDEX).addDocuments([data]);
  }

  /**
   * Deletes meilisearch document indexing from [posts-and-comments] index.
   *
   * @param context Event context
   * @return Promise
   */
  static deleteIndexedForumDocument(context: EventContext) {
    return this.client.index(this.FORUM_INDEX).deleteDocument(context.params.id);
  }

  /**
   * Creates a post document index.
   *
   * @param data post data to index
   * @param context Event context
   * @return Promise
   *
   * @note
   *  - posts with a non existing category will not be indexed.
   *  - posts with `quiz` category will not be indexed.
   */
  static async indexPostCreate(data: PostDocument, context: EventContext) {
    const cats = await Ref.categoryCol.get();
    const dbCategories: string[] = cats.docs.map((doc) => doc.id);

    // don't index posts with unknown category.
    if (dbCategories.includes(data.category) == false) return null;
    // don't index posts under excluded categories, like `quiz`.
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

    promises.push(this.client.index(this.POSTS_INDEX).addDocuments([_data]));
    promises.push(this.indexForumDocument(_data));

    return Promise.all(promises);
  }

  /**
   * Update a post document index.
   *
   * @param data post data before and after.
   * @param context Event context
   * @return Promise
   *
   * @note
   *  - posts with a non existing category will not be indexed.
   *  - posts with `quiz` category will not be indexed.
   *  - posts with the same title and content before and after update will not be indexed.
   *
   * @test tests/meilisearch/post-update.spect.ts
   */
  static async indexPostUpdate(
      data: { before: PostDocument; after: PostDocument },
      context: EventContext
  ): Promise<any> {
    const cats = await Ref.categoryCol.get();
    const dbCategories: string[] = cats.docs.map((doc) => doc.id);

    // don't index posts with unknown category.
    if (dbCategories.includes(data.after.category) == false) return null;
    // don't index posts with category matching from list of excluded categories.
    if (this.excludedCategories.includes(data.after.category)) return null;
    // don't index posts if both post and title didn't change.
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

    promises.push(this.client.index(this.POSTS_INDEX).updateDocuments([_data]));
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
    promises.push(this.client.index(this.POSTS_INDEX).deleteDocument(context.params.id));
    promises.push(this.deleteIndexedForumDocument(context));
    return Promise.all(promises);
  }

  /**
   * Creates a comment document index.
   *
   * @param data Document data
   * @param context Event context
   * @return Promise
   *
   * @note
   *  - comments without postId or parentId will not be indexed.
   */
  static async indexCommentCreate(data: CommentDocument, context: EventContext) {
    // don't index comments without postId or parentId.
    if (!data.postId || !data.parentId) return null;

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

    promises.push(this.client.index(this.COMMENTS_INDEX).addDocuments([_data]));
    promises.push(this.indexForumDocument(_data));

    return Promise.all(promises);
  }

  /**
   * Updates a comment document index.
   *
   * @param data comment data before and after.
   * @param context Event context
   * @return Promise
   */
  static async indexCommentUpdate(
      data: { before: CommentDocument; after: CommentDocument },
      context: EventContext
  ) {
    if (data.before.content === data.after.content) return null;
    // don't index comments without postId or parentId.
    if (!data.after.postId || !data.after.parentId) return null;

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

    promises.push(this.client.index(this.COMMENTS_INDEX).updateDocuments([_data]));
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
    promises.push(this.client.index(this.COMMENTS_INDEX).deleteDocument(context.params.id));
    promises.push(this.deleteIndexedForumDocument(context));
    return Promise.all(promises);
  }

  /**
   * Indexes user data coming from create event of auth.
   *
   * @param data User data to index. It must also contain the users id.
   * @return promise
   */
  static async indexUserCreate(data: UserRecord): Promise<any> {
    const _data = {
      id: data.uid,
      photoUrl: data.photoURL ?? "",
      registeredAt: Utils.getTimestamp(),
      updatedAt: Utils.getTimestamp(),
    };

    return this.client.index(this.USERS_INDEX).addDocuments([_data]);
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
      before.lastName === after.lastName &&
      before.gender === after.gender &&
      before.photoUrl === after.photoUrl
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
      updatedAt: Utils.getTimestamp(),
    };

    return this.client.index(this.USERS_INDEX).addDocuments([_data]);
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
    promises.push(Ref.rdb.ref(this.USERS_INDEX).child(uid).remove());
    promises.push(Ref.rdb.ref(this.USER_SETTINGS).child(uid).remove());
    promises.push(Ref.db.collection(this.QUIZ_HISTORY).doc(uid).delete());
    promises.push(this.client.index(this.USERS_INDEX).deleteDocument(uid));
    return Promise.all(promises);
  }

  /**
   * Search - this will run a meilisearch search query.
   *
   * @param index
   * @param data search options
   * @returns Search result
   */
  static async search(
      index: string,
      data: { keyword?: string; id?: string }
  ): Promise<SearchResponse<Record<string, any>>> {
    const searchFilters = [];

    if (data.id) searchFilters.push("id=" + data.id);

    return this.client.index(index).search(data.keyword, {
      filter: searchFilters,
    });
  }
}
