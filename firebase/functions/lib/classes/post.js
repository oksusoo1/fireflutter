"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Post = void 0;
const admin = require("firebase-admin");
const dayjs = require("dayjs");
const dayOfYear = require("dayjs/plugin/dayOfYear");
const weekOfYear = require("dayjs/plugin/weekOfYear");
dayjs.extend(dayOfYear);
dayjs.extend(weekOfYear);
const ref_1 = require("./ref");
const defines_1 = require("../defines");
const messaging_1 = require("./messaging");
const storage_1 = require("./storage");
const category_1 = require("./category");
const point_1 = require("./point");
const utils_1 = require("./utils");
const user_1 = require("./user");
class Post {
    /**
     *
     * @see README.md for details.
     * @param options options for getting post lists
     * @returns
     * - list of post documents. Empty array will be returned if there is no posts by the options.
     * - Or it will throw an exception on failing post creation.
     * @note exception will be thrown on error.
     */
    static async list(options) {
        const posts = [];
        let q = ref_1.Ref.postCol;
        if (options.category) {
            q = q.where("category", "==", options.category);
        }
        q = q.orderBy("createdAt", "desc");
        if (options.startAfter) {
            q = q.startAfter(parseInt(options.startAfter));
        }
        const limit = options.limit ? parseInt(options.limit) : 10;
        q = q.limit(limit);
        const snapshot = await q.get();
        if (snapshot.size > 0) {
            const docs = snapshot.docs;
            for (const doc of docs) {
                const post = doc.data();
                post.id = doc.id;
                if (options.content === "N")
                    delete post.content;
                if (options.author !== "N")
                    await this.addAuthorMeta(post);
                posts.push(post);
            }
        }
        return posts;
    }
    /**
     * Returns a post view data that includes comments and all of meta data of the comments.
     * @param data options for post view.
     */
    static async view(data) {
        const post = await this.get(data.id);
        if (post === null)
            throw defines_1.ERROR_POST_NOT_EXIST;
        // Add user meta: Name (first + last), level, photoUrl.
        await this.addAuthorMeta(post);
        // Get post comments.
        const snapshot = await ref_1.Ref.commentCol.where("postId", "==", post.id).orderBy("createdAt").get();
        const comments = [];
        if (snapshot.empty === false) {
            for (const doc of snapshot.docs) {
                const comment = doc.data();
                comment.id = doc.id;
                await this.addAuthorMeta(comment);
                if (comment.postId == comment.parentId) {
                    // Add at bottom
                    comment.depth = 0;
                    comments.push(comment);
                }
                else {
                    // It's a comment under another comemnt. Find parent.
                    const i = comments.findIndex((e) => e.id == comment.parentId);
                    if (i >= 0) {
                        comment.depth = comments[i].depth + 1;
                        comments.splice(i + 1, 0, comment);
                    }
                }
            }
        }
        post.comments = comments;
        return post;
    }
    /**
     *
     * @see README.md for details.
     * @param data post doc data to be created. See README.md for details.
     * @returns
     * - post doc as in PostDocument interface after create. Note that, it will contain post id.
     * - Or it will throw an exception on failing post creation.
     * @note exception will be thrown on error.
     */
    static async create(data) {
        // check up
        if (!data.uid)
            throw defines_1.ERROR_EMPTY_UID;
        if (!data.category)
            throw defines_1.ERROR_EMPTY_CATEGORY;
        // Ref.categoryDoc(data.category);
        // const re = await Category.exists(data.category);
        const category = await category_1.Category.get(data.category);
        if (category === null)
            throw defines_1.ERROR_CATEGORY_NOT_EXISTS;
        // get all the data from client.
        const doc = data;
        // sanitize
        if (typeof doc.files === "undefined") {
            doc.files = [];
        }
        // default data
        data.hasPhoto = data.files && data.files.length > 0;
        doc.deleted = false;
        doc.noOfComments = 0;
        doc.year = dayjs().year();
        doc.month = dayjs().month() + 1;
        doc.day = dayjs().date();
        doc.dayOfYear = dayjs().dayOfYear();
        doc.week = dayjs().week();
        doc.createdAt = utils_1.Utils.getTimestamp();
        doc.updatedAt = utils_1.Utils.getTimestamp();
        // Create post
        let ref;
        // Document id to be created of. See README.md for details.
        if (data.documentId) {
            ref = await ref_1.Ref.postDoc(data.documentId).set(doc);
            ref = ref_1.Ref.postDoc(data.documentId);
        }
        else {
            ref = await ref_1.Ref.postCol.add(doc);
        }
        // Post create event
        await point_1.Point.postCreatePoint(category, data.uid, ref.id);
        // return the document object of newly created post.
        const snapshot = await ref.get();
        // Post create success
        const post = snapshot.data();
        post.id = ref.id;
        return post;
    }
    /**
     * Updates a post
     * @param data data to update the post
     * - data.id as post id is required.
     * - data.uid as post owner's uid is required.
     * @returns the post as PostDocument
     *
     * @note it throws exceptions on error.
     */
    static async update(data) {
        if (!data.id)
            throw defines_1.ERROR_EMPTY_ID;
        const post = await this.get(data.id);
        if (post === null)
            throw defines_1.ERROR_POST_NOT_EXIST;
        if (post.uid !== data.uid)
            throw defines_1.ERROR_NOT_YOUR_POST;
        const id = data.id;
        delete data.id;
        // updatedAt
        data.updatedAt = utils_1.Utils.getTimestamp();
        // hasPhoto
        data.hasPhoto = data.files && data.files.length > 0;
        await ref_1.Ref.postDoc(id).update(data);
        const updated = await this.get(id);
        if (updated === null)
            throw defines_1.ERROR_UPDATE_FAILED;
        updated.id = id;
        return updated;
    }
    static async delete(data) {
        var _a;
        // 1. id must be present. if not throw ERROR_EMPTY_ID;
        if (!data.id)
            throw defines_1.ERROR_EMPTY_ID;
        const id = data.id;
        // 2. get the post.
        const post = await this.get(id);
        // 3. if it's null(not exists), throw ERROR_POST_NOT_EXITS,
        if (post === null)
            throw defines_1.ERROR_POST_NOT_EXIST;
        // 4. check uid and if it's not the same of the document, throw ERROR_NOT_YOUR_POST;
        if (post.uid !== data.uid)
            throw defines_1.ERROR_NOT_YOUR_POST;
        // 5. if the post had been marked as deleted, then throw ERROR_ALREADY_DELETED.
        if (post.deleted && post.deleted === true)
            throw defines_1.ERROR_ALREADY_DELETED;
        // 6. if post has files, delete files from firebase storage.
        if ((_a = post.files) === null || _a === void 0 ? void 0 : _a.length) {
            for (const url of post.files) {
                await storage_1.Storage.deleteFileFromUrl(url);
            }
        }
        const postRef = ref_1.Ref.postDoc(id);
        if (!post.noOfComments) {
            // 7.A if there is no comment, then delete the post.
            await postRef.delete();
            return { id: id };
        }
        else {
            // 7.B or if there is a comment, then mark it as deleted. (deleted=true)
            post.title = "";
            post.content = "";
            post.deleted = true;
            await postRef.update(post);
        }
        return { id: id };
    }
    /**
     * Increase no of comments.
     *
     * Use this method to increase the no of comment on the post when there is new comment.
     */
    static async increaseNoOfComments(postId) {
        return ref_1.Ref.postDoc(postId).update({ noOfComments: admin.firestore.FieldValue.increment(1) });
    }
    static async decreaseNoOfComments(postId) {
        return ref_1.Ref.postDoc(postId).update({ noOfComments: admin.firestore.FieldValue.increment(-1) });
    }
    /**
     * Returns a post as PostDocument or null if the post does not exists.
     * @param id post id
     * @returns post document or null if the post does not exitss.
     */
    static async get(id) {
        const snapshot = await ref_1.Ref.postDoc(id).get();
        if (snapshot.exists) {
            // return snapshot.data() as PostDocument;
            const data = snapshot.data();
            if (data) {
                data.id = id;
                return data;
            }
        }
        return null;
    }
    static async sendMessageOnCreate(data, id) {
        var _a, _b;
        const category = data.category;
        const payload = messaging_1.Messaging.topicPayload("posts_" + category, {
            title: (_a = data.title) !== null && _a !== void 0 ? _a : "",
            body: (_b = data.content) !== null && _b !== void 0 ? _b : "",
            postId: id,
            type: "post",
            uid: data.uid,
        });
        return admin.messaging().send(payload);
    }
    /**
     * Adds author information on the document.
     *
     * @param postOrComment post or comment document
     * @returns returns post with author's information included.
     */
    static async addAuthorMeta(postOrComment) {
        var _a, _b, _c, _d;
        const userData = await user_1.User.get(postOrComment.uid);
        if (userData != null) {
            postOrComment.author = `${(_a = userData === null || userData === void 0 ? void 0 : userData.firstName) !== null && _a !== void 0 ? _a : ""} ${(_b = userData === null || userData === void 0 ? void 0 : userData.lastName) !== null && _b !== void 0 ? _b : ""}`;
            postOrComment.authorLevel = (_c = userData === null || userData === void 0 ? void 0 : userData.level) !== null && _c !== void 0 ? _c : 0;
            postOrComment.authorPhotoUrl = (_d = userData === null || userData === void 0 ? void 0 : userData.photoUrl) !== null && _d !== void 0 ? _d : "";
        }
        return postOrComment;
    }
}
exports.Post = Post;
//# sourceMappingURL=post.js.map