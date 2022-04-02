"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.MeilisearchIndex = void 0;
const axios_1 = require("axios");
const utils_1 = require("./utils");
/**
 * TODO: Test
 * - indexPostDocument
 * - deleteIndexedPostDocument
 * - indexCommentDocument
 * - deleteIndexedCommentDocument
 * - indexUserDocument
 * - deleteIndexedUserDocument
 */
class MeilisearchIndex {
    /**
     * Index
     * @param data data to be index
     * @return Promise<any>
     */
    static indexForumDocument(data) {
        return axios_1.default.post("http://wonderfulkorea.kr:7700/indexes/posts-and-comments/documents", data);
    }
    /**
     *
     * @param id document ID to delete
     * @return Promise
     */
    static deleteIndexedForumDocument(id) {
        return axios_1.default.delete("http://wonderfulkorea.kr:7700/indexes/posts-and-comments/documents/" + id);
    }
    /**
     * Creates or update a post document index.
     *
     * @param id post id
     * @param data post data to index
     * @return Promise
     */
    static async indexPostDocument(id, data) {
        var _a, _b, _c;
        let _files = "";
        if (data.files && data.files.length) {
            _files = typeof data.files == "string" ? data.files : data.files.join(",");
        }
        const _data = {
            id: id,
            uid: data.uid,
            title: (_a = data.title) !== null && _a !== void 0 ? _a : "",
            category: data.category,
            content: (_b = data.content) !== null && _b !== void 0 ? _b : "",
            files: _files,
            noOfComments: (_c = data.noOfComments) !== null && _c !== void 0 ? _c : 0,
            deleted: data.deleted ? "Y" : "N",
            createdAt: utils_1.Utils.getTimestamp(data.createdAt),
            updatedAt: utils_1.Utils.getTimestamp(data.updatedAt),
        };
        const promises = [];
        promises.push(axios_1.default.post("https://wonderfulkorea.kr:4431/index.php?api=post/record", _data));
        if (!this.meilisearchExcludedCategories.includes(_data.category)) {
            _data.content = utils_1.Utils.removeHtmlTags(_data.content);
            promises.push(axios_1.default.post("http://wonderfulkorea.kr:7700/indexes/posts/documents", _data));
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
    static async deleteIndexedPostDocument(id) {
        const promises = [];
        promises.push(axios_1.default.post("https://wonderfulkorea.kr:4431/index.php?api=post/delete", {
            id: id,
        }));
        promises.push(axios_1.default.delete("http://wonderfulkorea.kr:7700/indexes/posts/documents/" + id));
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
    static async indexCommentDocument(id, data) {
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
            createdAt: utils_1.Utils.getTimestamp(data.createdAt),
            updatedAt: utils_1.Utils.getTimestamp(data.updatedAt),
        };
        const promises = [];
        promises.push(axios_1.default.post("https://wonderfulkorea.kr:4431/index.php?api=post/record", _data));
        _data.content = utils_1.Utils.removeHtmlTags(_data.content);
        promises.push(axios_1.default.post("http://wonderfulkorea.kr:7700/indexes/comments/documents", _data));
        promises.push(this.indexForumDocument(_data));
        return Promise.all(promises);
    }
    /**
     * Deletes indexed comment document.
     *
     * @param id Comment ID of the document to be deleted.
     * @return Promise
     */
    static async deleteIndexedCommentDocument(id) {
        const promises = [];
        promises.push(axios_1.default.post("https://wonderfulkorea.kr:4431/index.php?api=post/delete", {
            id: id,
        }));
        promises.push(axios_1.default.delete("http://wonderfulkorea.kr:7700/indexes/comments/documents/" + id));
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
    async indexUserDocument(uid, data = {}) {
        var _a, _b, _c, _d, _e;
        const _data = {
            id: uid,
            gender: (_a = data.gender) !== null && _a !== void 0 ? _a : "",
            firstName: (_b = data.firstName) !== null && _b !== void 0 ? _b : "",
            middleName: (_c = data.middleName) !== null && _c !== void 0 ? _c : "",
            lastName: (_d = data.lastName) !== null && _d !== void 0 ? _d : "",
            photoUrl: (_e = data.photoUrl) !== null && _e !== void 0 ? _e : "",
        };
        return axios_1.default.post("http://wonderfulkorea.kr:7700/indexes/users/documents", _data);
    }
    /**
     * Deletes user related documents on realtime database and meilisearch indexing.
     *
     * @param {*} uid user id to delete.
     * @return promise
     */
    async deleteIndexedUserDocument(uid) {
        const promises = [];
        // Remove user data under it's uid from:
        // - 'users' and 'user-settings' realtime database,
        // - 'quiz-history' firestore database.
        // promises.push(rdb.ref("users").child(uid).remove());
        // promises.push(rdb.ref("user-settings").child(uid).remove());
        // promises.push(db.collection("quiz-history").doc(uid).delete());
        promises.push(axios_1.default.delete("http://wonderfulkorea.kr:7700/indexes/users/documents/" + uid));
        return Promise.all(promises);
    }
    // / FOR TESTING
    // / TODO: move this code somewhere else.
    static createTestPostDocument(data) {
        var _a, _b, _c;
        return {
            id: data.id,
            uid: (_a = data.uid) !== null && _a !== void 0 ? _a : new Date().getTime().toString(),
            title: (_b = data.title) !== null && _b !== void 0 ? _b : new Date().getTime().toString(),
            content: (_c = data.content) !== null && _c !== void 0 ? _c : new Date().getTime().toString(),
            category: "test-cat",
            deleted: "N",
        };
    }
}
exports.MeilisearchIndex = MeilisearchIndex;
MeilisearchIndex.meilisearchExcludedCategories = ["quiz"];
//# sourceMappingURL=meilisearch-index.js.map