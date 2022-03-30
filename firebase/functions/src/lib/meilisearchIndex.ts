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

export class MeilisearchIndex {
  static meilisearchExcludedCategories = ["quiz"];

  /**
   *
   * @param data data to be indexed.
   * @returns Promise
   */
  static indexForumDocument(data: PostDocument | CommentDocument): Promise<any> {
    return axios.post("http://wonderfulkorea.kr:7700/indexes/posts-and-comments/documents", data);
  }

  /**
   * 
   * @param id document ID to delete
   * @returns Promise
   */
  static deleteIndexedForumDocument(id: string) {
    return axios.delete("http://wonderfulkorea.kr:7700/indexes/posts-and-comments/documents/" + id);
  }

  /**
   * Indexes a post
   *
   * @param id post id
   * @param data post data to index
   * @returns Promise
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
  

  /// FOR TESTING
  /// TODO: move this code somewhere else.
  static createTestPostDocument(data: { id: string; uid?: string; title?: string; content?: string }): PostDocument {
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
