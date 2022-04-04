import { FirebaseAppInitializer } from "../firebase-app-initializer";
import { Index, MeiliSearch as Meili } from "meilisearch";
import * as admin from "firebase-admin";

import { UserModel } from "../../functions/src/interfaces/user.interface";
import { Utils } from "../../functions/src/classes/utils";

new FirebaseAppInitializer();
const fsdb = admin.firestore();
const rdb = admin.database();

export class Meilisearch {
  static readonly deleteOptions = ["-dd", "-deleteDocs"];

  static readonly COMMENT_INDEX = "comments";
  static readonly POST_INDEX = "posts";
  static readonly USER_INDEX = "users";

  static readonly FORUM_INDEXES = [this.COMMENT_INDEX, this.POST_INDEX];
  static readonly INDEXES = [...this.FORUM_INDEXES, this.USER_INDEX];

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

  /**
   * Deletes documents under given index ID.
   *
   * @param indexId index ID
   * @returns
   */
  static async deleteIndexedDocuments(indexId: string) {
    console.log("Deleting documents under " + indexId + " index.");

    if (this.FORUM_INDEXES.includes(indexId)) {
      await this.forumIndex.deleteAllDocuments();
    }

    return this.client.index(indexId).deleteAllDocuments();
  }

  /**
   * Re-indexes documents under given index ID if it is valid or exists.
   *
   * @param indexId Index ID
   * @param deleteDocs Delete documents option.
   *  If set to `true` it will delete documents under given index first before proceeding with re-indexing process.
   *  defaults to `false`.
   */
  static async reIndex(indexId: string, deleteDocs: boolean = false): Promise<void> {
    // If index is wrong return.
    if (!this.INDEXES.includes(indexId)) {
      console.log("INDEX NOT FOUND FOR ", indexId);
      return;
    }

    // If delete docs option is true, delete documents first.
    if (deleteDocs) {
      await this.deleteIndexedDocuments(indexId);
    }

    if (this.FORUM_INDEXES.includes(indexId)) {
      // re-index forum
      // await this.indexForum(indexId);
      await this.indexForum(indexId);
    } else {
      // re-index users
      // await this.indexUsers();
      await this.indexUsers();
      console.log("users reindex");
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
    // const dataList: UserModel[] = Object.entries(docs.val())
    let count = 1;
    for (const [key, value] of Object.entries<UserModel>(docs.val())) {
      const _data = {
        id: key,
        gender: value.gender ?? "",
        firstName: value.firstName ?? "",
        middleName: value.middleName ?? "",
        lastName: value.lastName ?? "",
        photoUrl: value.photoUrl ?? "",
      };

      // console.log(_data);
      console.log("[INDEXING]: " + count + " | " + key, _data.firstName);
      // await this.usersIndex.addDocuments([_data]);
      count++;
    }
  }

  /**
   * Reindexes document under given indexId.
   *
   * @param indexId index
   * @returns
   */
  static async indexForum(indexId: string): Promise<void> {
    const col = fsdb.collection(indexId);

    // Read documents (exclude deleted documents).
    const docs = await col.where("deleted", "==", false).get();

    // Nothing to index.
    if (docs.empty) {
      console.log("[NOTICE]: No documents found under " + indexId + " index.");
      return;
    }

    // Print total size/number of document collection.
    let count = 1;
    console.log("re-indexing " + docs.size + " documents under " + indexId + " index.");
    for (const doc of docs.docs) {
      const data = doc.data();

      // Forum index document.
      const _data = {
        id: doc.id,
        uid: data.uid,
        content: Utils.removeHtmlTags(data.content) ?? "",
        files: data.files && data.files.length ? data.files.join(",") : "",
        createdAt: Utils.getTimestamp(data.createdAt),
        updatedAt: Utils.getTimestamp(data.updatedAt),
      } as any;

      if (indexId == this.POST_INDEX) {
        // add necessary data if indexing for posts.
        _data.title = data.title ?? "";
      } else {
        // add necessary data if indexing for comments.
        _data.postId = data.postId;
        _data.parentId = data.parentId;
      }

      const promises = [this.forumIndex.addDocuments([_data])];
      if (indexId == this.POST_INDEX) {
        promises.push(this.postsIndex.addDocuments([_data]));
      } else {
        promises.push(this.commentsIndex.addDocuments([_data]));
      }

      // console.log(_data);
      console.log("[INDEXING]: " + count + " | " + doc.id, data.title ?? data.content);
      // await Promise.all(promises);
      count++;
    }
  }
}
