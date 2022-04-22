import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Index, MeiliSearch as Meili } from "meilisearch";
import * as admin from "firebase-admin";

import { UserDocument } from "../../functions/src/interfaces/user.interface";
import { PostDocument, CommentDocument } from "../../functions/src/interfaces/forum.interface";
import { Utils } from "../../functions/src/classes/utils";

new FirebaseAppInitializer();
const fsdb = admin.firestore();
const rdb = admin.database();

export interface IndexingResult {
  success: number;
  failedDocs: string[];
  deleted?: number;
  remarks?: string;
}
export class Meilisearch {
  static readonly FORUM_SCOPE = "forum";
  static readonly USERS_SCOPE = "users";
  static readonly deleteOptions = ["-dd"];

  static readonly COMMENT_INDEX = "comments";
  static readonly POST_INDEX = "posts";
  static readonly USER_INDEX = "users";
  static readonly EXCLUDED_CATEGORIES = ["quiz"];

  static readonly FORUM_INDEXES = ["posts", "comments"];

  static readonly client = new Meili({
    host: "http://wonderfulkorea.kr:7700",
  });

  static get usersIndex(): Index {
    return this.client.index(this.USER_INDEX);
  }
  static get postsIndex(): Index {
    return this.client.index(this.POST_INDEX);
  }
  static get commentsIndex(): Index {
    return this.client.index(this.COMMENT_INDEX);
  }
  static get forumIndex(): Index {
    return this.client.index("posts-and-comments");
  }


  static async resetSearchSettings() {
    const promises = [];

    /// users index
    promises.push(this.client.index(this.USER_INDEX).updateSettings({
      displayedAttributes: ['*'],
      searchableAttributes: ['*'],
      sortableAttributes: ['registeredAt'],
      filterableAttributes: ["id"],
      rankingRules: ["words","typo","proximity","attribute","sort","exactness"],
    }))
    /// posts-and-comments index
    promises.push(this.client.index('posts-and-comments').updateSettings({
      displayedAttributes: ['*'],
      sortableAttributes: ['createdAt'],
      searchableAttributes: ['title', 'content'],
      filterableAttributes: ["category","id","uid"],
      rankingRules: ["words","exactness","typo","attribute","proximity","sort"],
    }))
    /// posts index
    promises.push(this.client.index(this.POST_INDEX).updateSettings({
      displayedAttributes: ['*'],
      sortableAttributes: ['createdAt'],
      searchableAttributes: ['title', 'content'],
      filterableAttributes: ["category","id","uid"],
      rankingRules: ["words","exactness","typo","attribute","proximity","sort"],
    }))
    /// comments index
    promises.push(this.client.index(this.COMMENT_INDEX).updateSettings({
      displayedAttributes: ['*'],
      sortableAttributes: ['createdAt'],
      searchableAttributes: ['content'],
      filterableAttributes: ["id","uid"],
      rankingRules: ["words","exactness","typo","attribute","proximity","sort"],
    }))

    return Promise.all(promises);
  }

  /**
   * Deletes documents under given index ID.
   *
   * @param indexId index ID
   * @returns
   */
  static async deleteIndexedDocuments(indexId: string) {
    console.log("Deleting documents under " + indexId + " index.");
    return this.client.index(indexId).deleteAllDocuments();
  }

  /**
   * Deletes documents under 'posts-and-comments' index.
   */
  static async deleteForumDocuments() {
    return this.forumIndex.deleteAllDocuments();
  }

  /**
   * Re-indexes documents under given index ID if it is valid or exists.
   *
   * @param scope A scope of which the re-indexing process will be executed.
   * @param deleteDocs Delete documents option.
   *  If set to `true` it will delete documents under given index first before proceeding with re-indexing process.
   *  defaults to `false`.
   */
  static async reIndexDocuments(scope: string, deleteDocs: boolean = false): Promise<void> {
    // If index is wrong return.
    if (![this.FORUM_SCOPE, this.USERS_SCOPE].includes(scope)) {
      console.log(`No indexing process found for ${scope}.`);
      return;
    }

    if (scope == this.FORUM_SCOPE) {
      if (deleteDocs) {
        await this.deleteForumDocuments();
        await this.deleteIndexedDocuments(this.POST_INDEX);
        await this.deleteIndexedDocuments(this.COMMENT_INDEX);
      }

      await this.indexForum(this.POST_INDEX);
      await this.indexForum(this.COMMENT_INDEX);
    } else {
      if (deleteDocs) {
        await this.deleteIndexedDocuments(this.USER_INDEX);
      }
      await this.indexUsers();
    }
  }

  /**
   * Re-indexes 'users' index.
   *
   * @returns Promise<void>
   */
  static async indexUsers(): Promise<void> {
    const col = rdb.ref("users");
    const docs = await col.get();

    if (!docs.numChildren()) {
      console.log("No user documents to index.");
      return;
    }

    console.log("Re-indexing " + docs.numChildren() + " of user documents.");
    let success = 0;
    let failed: string[] = [];
    for (const [key, value] of Object.entries<UserDocument>(docs.val())) {
      const _data = {
        // If id contains symbols other than "-" and "_" it will not be indexed, an error will not occur.
        // It will simply get ignored.
        id: key,
        gender: value.gender ?? "",
        firstName: value.firstName ?? "",
        middleName: value.middleName ?? "",
        lastName: value.lastName ?? "",
        photoUrl: value.photoUrl ?? "",
        registeredAt: value.registeredAt,
        updatedAt: value.updatedAt,
      };

      try {
        await this.usersIndex.addDocuments([_data]);
        success++;
        console.log(`[SUCCESS]: ${key} | ${_data.firstName}`);
      } catch (error) {
        console.error(`[FAILED]: ${key} | Error - ${error}`);
        failed.push(key);
      }
    }
    this.printSummary({ success: success, failedDocs: failed }, this.USER_INDEX, docs.numChildren());
  }

  /**
   * Reindexes document under given indexId.
   *
   * @param indexId index
   * @returns 
   * 
   */
  static async indexForum(indexId: string): Promise<void> {
    const col = fsdb.collection(indexId);
    const docsSnapshot = await col.get();

    // Nothing to index.
    if (docsSnapshot.empty) {
      console.log("[NOTICE]: No documents found under `posts` index.");
      return;
    }

    console.log(`Re-indexing ${docsSnapshot.size} documents under "${indexId}" index.`);

    let res: IndexingResult;
    if (indexId === this.POST_INDEX) {
      res = await this.indexPostDocuments(docsSnapshot.docs);
    } else {
      res = await this.indexCommentDocuments(docsSnapshot.docs);
    }

    this.printSummary(res, indexId, docsSnapshot.size);
  }

  /**
   * Indexes post documents.
   *
   * @param docs Document collection.
   * @returns indexing summary.
   * 
   * @note
   *  - posts with a non existing category will not be indexed.
   *  - posts with `quiz` category will not be indexed.
   */
  static async indexPostDocuments(docs: Array<any>): Promise<IndexingResult> {
    const cats = await fsdb.collection("categories").get();
    const dbCategories: string[] = cats.docs.map((doc) => doc.id);

    let success = 0;
    let deleted = 0;
    let unknownCategory = 0;
    let quizDocs = 0;
    const failedIds: string[] = [];
    const categories: string[] = [];

    for (const doc of docs) {
      const data = doc.data() as PostDocument;

      // skip deleted data.
      if (data.deleted && data.deleted == true) {
        deleted++;
        continue;
      }

      // don't index posts with unknown category.
      if (dbCategories.includes(data.category) == false) {
        unknownCategory++;
        continue;
      }

      // skip excluded categories.
      if (data.category && this.EXCLUDED_CATEGORIES.includes(data.category)) {
        quizDocs++;
        continue;
      }

      // Forum index document.
      const _data = {
        // If id contains symbols other than "-" and "_" it will not be indexed, an error will not occur.
        // It will simply get ignored.
        id: doc.id,
        uid: data.uid,
        title: data.title ?? "",
        category: data.category,
        content: Utils.removeHtmlTags(data.content) ?? "",
        files: data.files && data.files.length ? data.files.join(",") : "",
        createdAt: Utils.getTimestamp(data.createdAt),
        updatedAt: Utils.getTimestamp(data.updatedAt),
      } as any;

      const promises = [this.forumIndex.addDocuments([_data]), this.postsIndex.addDocuments([_data])];
      const titleLog = data.title?.length ? _data.title.substring(0, 15) : "";

      try {
        await Promise.all(promises);
        if (data.category && !categories.includes(data.category)) {
          categories.push(data.category);
        }
        console.log(`[INDEXED]: ${doc.id} | ${titleLog}...`);
        success++;
      } catch (error) {
        console.error(`[FAILED]: ${doc.id} | Reason: ${error}`);
        failedIds.push(doc.id);
      }
    }

    return {
      success: success,
      failedDocs: failedIds,
      deleted: deleted,
      remarks: `\n ${unknownCategory} documents with unknown category \n - ${quizDocs} 'quiz' documents.\n - Categories from indexed posts - ${categories.join(
        ", "
      )}`,
    };
  }

  /**
   * Indexes comment documents from firestore database.
   *
   * @param docs Document array.
   * @returns summary of indexing result.
   * 
   * @note
   *  - comments without postId or parentId will not be indexed.
   */
  static async indexCommentDocuments(docs: Array<any>): Promise<IndexingResult> {
    let success = 0;
    let deleted = 0;
    let noPostOrParentId = 0;
    const failedIds: string[] = [];

    for (const doc of docs) {
      const data = doc.data() as CommentDocument;

      // skip deleted data.
      if (data.deleted && data.deleted == true) {
        deleted++;
        continue;
      }

      // don't index comments without postId or parentId.
      if (!data.postId || !data.parentId) {
        noPostOrParentId++;
        continue;
      }

      // Forum index document.
      const _data = {
        // If id contains symbols other than "-" and "_" it will not be indexed, an error will not occur.
        // It will simply get ignored.
        id: doc.id,
        uid: data.uid,
        postId: data.postId,
        parentId: data.parentId,
        content: Utils.removeHtmlTags(data.content) ?? "",
        files: data.files && data.files.length ? data.files.join(",") : "",
        createdAt: Utils.getTimestamp(data.createdAt),
        updatedAt: Utils.getTimestamp(data.updatedAt),
      } as any;

      const promises = [this.forumIndex.addDocuments([_data]), this.commentsIndex.addDocuments([_data])];
      const contentLog = data.content?.length ? _data.content.substring(0, 15) : "";

      try {
        await Promise.all(promises);
        console.log(`[INDEXED]: ${doc.id} | ${contentLog}...`);
        success++;
      } catch (error) {
        console.error(`[FAILED]: ${doc.id} | Reason: ${error}`);
        failedIds.push(doc.id);
      }
    }

    return {
      success: success,
      failedDocs: failedIds,
      deleted: deleted,
      remarks: ` - ${noPostOrParentId} comments without parentId or postId`,
    };
  }

  /**
   * Print out a summary of indexing.
   *
   * @param result result of indexing.
   * @param indexId Index ID.
   * @param total total document size.
   */
  static printSummary(result: IndexingResult, indexId: string, total: number) {
    console.log("==============================================================");

    // Total documents.
    console.log(`Total of ${total} documents under '${indexId}' collection on database.`);

    // Deleted.
    if (result.deleted) console.log(`[MARK AS DELETED]: ${result.deleted} documents.`);

    // Successful indexed.
    console.log(`[SUCCESSFULLY INDEXED]: ${result.success} documents.`);

    // Failed indexing.
    if (result.failedDocs.length) {
      console.log("[FAILED INDEXING]");
      console.log(`- Failed to index ${result.failedDocs.length} documents.`);
      console.log(`- Document IDs: ${result.failedDocs.join(", ")}`);
    }

    // Remarks
    if (result.remarks) {
      console.log(`[REMARKS]: ${result.remarks}`);
    }
    console.log("\n");
  }
}
