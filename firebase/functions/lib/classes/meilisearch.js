"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Meilisearch = void 0;
const ref_1 = require("./ref");
const utils_1 = require("./utils");
const meilisearch_1 = require("meilisearch");
class Meilisearch {
    /**
     * Indexes document under [posts-and-comments] index.
     * @param data data to be index
     * @return Promise<any>
     */
    static indexForumDocument(data) {
        return this.client.index("posts-and-comments").addDocuments([data]);
    }
    /**
     * Deletes meilisearch document indexing from [posts-and-comments] index.
     *
     * @param context Event context
     * @return Promise
     */
    static deleteIndexedForumDocument(context) {
        return this.client.index("posts-and-comments").deleteDocument(context.params.id);
    }
    /**
     * Creates a post document index.
     *
     * @param data post data to index
     * @param context Event context
     * @return Promise
     */
    static async indexPostCreate(data, context) {
        var _a, _b, _c;
        if (this.excludedCategories.includes(data.category))
            return null;
        const _data = {
            id: context.params.id,
            uid: data.uid,
            title: (_a = data.title) !== null && _a !== void 0 ? _a : "",
            category: data.category,
            content: (_b = utils_1.Utils.removeHtmlTags(data.content)) !== null && _b !== void 0 ? _b : "",
            files: data.files ? data.files.join(",") : "",
            noOfComments: (_c = data.noOfComments) !== null && _c !== void 0 ? _c : 0,
            deleted: false,
            createdAt: utils_1.Utils.getTimestamp(),
            updatedAt: utils_1.Utils.getTimestamp(),
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
    static async indexPostUpdate(data, context) {
        var _a;
        if (this.excludedCategories.includes(data.after.category))
            return null;
        if (data.before.title === data.after.title && data.before.content === data.after.content) {
            return null;
        }
        const after = data.after;
        const _data = {
            id: context.params.id,
            uid: after.uid,
            category: after.category,
            title: (_a = after.title) !== null && _a !== void 0 ? _a : "",
            content: utils_1.Utils.removeHtmlTags(after.content),
            files: after.files ? after.files.join(",") : "",
            noOfComments: after.noOfComments,
            deleted: false,
            updatedAt: utils_1.Utils.getTimestamp(),
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
    static async deleteIndexedPostDocument(context) {
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
    static async indexCommentCreate(data, context) {
        var _a;
        const _data = {
            id: context.params.id,
            uid: data.uid,
            postId: data.postId,
            parentId: data.parentId,
            content: (_a = utils_1.Utils.removeHtmlTags(data.content)) !== null && _a !== void 0 ? _a : "",
            files: data.files ? data.files.join(",") : "",
            createdAt: utils_1.Utils.getTimestamp(),
            updatedAt: utils_1.Utils.getTimestamp(),
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
    static async indexCommentUpdate(data, context) {
        if (data.before.content === data.after.content)
            return null;
        const after = data.after;
        const _data = {
            id: context.params.id,
            uid: after.uid,
            postId: after.postId,
            parentId: after.parentId,
            content: utils_1.Utils.removeHtmlTags(after.content),
            files: after.files ? after.files.join(",") : "",
            updatedAt: utils_1.Utils.getTimestamp(after.updatedAt),
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
    static async deleteIndexedCommentDocument(context) {
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
    static async indexUserCreate(data) {
        var _a;
        const _data = {
            id: data.uid,
            photoUrl: (_a = data.photoURL) !== null && _a !== void 0 ? _a : "",
            registeredAt: utils_1.Utils.getTimestamp(),
            updatedAt: utils_1.Utils.getTimestamp(),
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
    static async indexUserUpdate(changes, context) {
        var _a, _b, _c, _d, _e, _f;
        const before = changes.before;
        const after = changes.after;
        if (before.firstName === after.firstName &&
            before.middleName === after.middleName &&
            before.lastName === after.lastName
        // Todo: add more ignore condition ? ...
        ) {
            return null;
        }
        const _data = {
            id: context.params.uid,
            photoUrl: (_a = after.photoUrl) !== null && _a !== void 0 ? _a : "",
            gender: (_b = after.gender) !== null && _b !== void 0 ? _b : "",
            firstName: (_c = after.firstName) !== null && _c !== void 0 ? _c : "",
            middleName: (_d = after.middleName) !== null && _d !== void 0 ? _d : "",
            lastName: (_e = after.lastName) !== null && _e !== void 0 ? _e : "",
            birthday: (_f = after.birthday) !== null && _f !== void 0 ? _f : 0,
            updatedAt: utils_1.Utils.getTimestamp(),
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
    static async deleteIndexedUserDocument(user) {
        const uid = user.uid;
        const promises = [];
        // Remove user data under it's uid from:
        // - 'users' and 'user-settings' realtime database,
        // - 'quiz-history' firestore database.
        promises.push(ref_1.Ref.rdb.ref("users").child(uid).remove());
        promises.push(ref_1.Ref.rdb.ref("user-settings").child(uid).remove());
        promises.push(ref_1.Ref.db.collection("quiz-history").doc(uid).delete());
        promises.push(this.client.index("users").deleteDocument(uid));
        return Promise.all(promises);
    }
    /**
     * Search - this will run a meilisearch search query.
     *
     * @param index
     * @param data search options
     * @returns Search result
     */
    static async search(index, data) {
        const searchFilters = [];
        if (data.id)
            searchFilters.push("id=" + data.id);
        return this.client.index(index).search(data.keyword, {
            filter: searchFilters,
        });
    }
}
exports.Meilisearch = Meilisearch;
Meilisearch.excludedCategories = ["quiz"];
Meilisearch.client = new meilisearch_1.MeiliSearch({
    host: "http://wonderfulkorea.kr:7700",
});
//# sourceMappingURL=meilisearch.js.map