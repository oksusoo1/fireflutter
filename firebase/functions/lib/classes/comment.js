"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Comment = void 0;
const admin = require("firebase-admin");
const ref_1 = require("./ref");
const defines_1 = require("../defines");
const storage_1 = require("./storage");
const point_1 = require("./point");
const post_1 = require("./post");
const utils_1 = require("./utils");
const messaging_1 = require("./messaging");
class Comment {
    /**
     * Creates a comment
     *
     * @param data comment doc data to be created
     * @returns comment doc data after create. Note that, it will contain post id.
     */
    static async create(data) {
        var _a, _b, _c;
        if (!data.uid)
            throw defines_1.ERROR_EMPTY_UID;
        const files = (_a = data.files) !== null && _a !== void 0 ? _a : [];
        const doc = {
            uid: data.uid,
            postId: data.postId,
            parentId: (_b = data.parentId) !== null && _b !== void 0 ? _b : "",
            content: (_c = data.content) !== null && _c !== void 0 ? _c : "",
            files: files,
            hasPhoto: files.length > 0,
            deleted: false,
            createdAt: utils_1.Utils.getTimestamp(),
            updatedAt: utils_1.Utils.getTimestamp(),
        };
        const ref = await ref_1.Ref.commentCol.add(doc);
        await point_1.Point.commentCreatePoint(data.uid, ref.id);
        await post_1.Post.increaseNoOfComments(data.postId);
        const snapshot = await ref.get();
        const comment = snapshot.data();
        comment.id = ref.id;
        return comment;
    }
    /**
     * Updates a comment
     *
     * @param data comment data to update with.
     * @returns updated comment doc data.
     */
    static async update(data) {
        if (!data.id)
            throw defines_1.ERROR_EMPTY_ID;
        if (!data.uid)
            throw defines_1.ERROR_EMPTY_UID;
        const id = data.id;
        const comment = await this.get(id);
        if (comment === null)
            throw defines_1.ERROR_COMMENT_NOT_EXISTS;
        if (comment.uid !== data.uid)
            throw defines_1.ERROR_NOT_YOUR_COMMENT;
        delete data.id;
        // updatedAt
        data.updatedAt = utils_1.Utils.getTimestamp();
        // hasPhoto
        if (data.files && data.files.length) {
            data.hasPhoto = true;
        }
        else {
            data.hasPhoto = false;
        }
        await ref_1.Ref.commentDoc(id).update(data);
        const updated = await this.get(id);
        if (updated === null)
            throw defines_1.ERROR_UPDATE_FAILED;
        return updated;
    }
    /**
     * Deletes a comment
     *
     * @param data
     *
     * @todo add types on `data`.
     */
    static async delete(data) {
        if (!data.id)
            throw defines_1.ERROR_EMPTY_ID;
        if (!data.uid)
            throw defines_1.ERROR_EMPTY_UID;
        const id = data.id;
        const comment = await this.get(id);
        if (comment === null)
            throw defines_1.ERROR_COMMENT_NOT_EXISTS;
        if (comment.deleted)
            throw defines_1.ERROR_ALREADY_DELETED;
        if (comment.uid !== data.uid)
            throw defines_1.ERROR_NOT_YOUR_COMMENT;
        if (comment.files && comment.files.length > 0) {
            for (const url of comment.files) {
                await storage_1.Storage.deleteFileFromUrl(url);
            }
        }
        // Check if child comment (of this comment) exists.
        // Get only 1 child.
        const snapshot = await ref_1.Ref.commentCol.where("parentId", "==", comment.id).limit(1).get();
        if (snapshot.size > 0) {
            // If child comment (of this comment) exists, then mark it as deleted.
            comment.content = "";
            comment.deleted = true;
            await ref_1.Ref.commentDoc(id).update(comment);
        }
        else {
            // If there is no comment (under this comment), then delete it.
            await ref_1.Ref.commentDoc(id).delete();
        }
        await post_1.Post.decreaseNoOfComments(comment.postId);
        return { id };
    }
    static async get(id) {
        const snapshot = await ref_1.Ref.commentDoc(id).get();
        if (snapshot.exists) {
            const comment = snapshot.data();
            comment.id = id;
            return comment;
        }
        return null;
    }
    static async sendMessageOnCreate(data, id) {
        const post = await post_1.Post.get(data.postId);
        if (!post)
            return null;
        const messageData = {
            title: post.title,
            body: data.content,
            postId: data.postId,
            type: "post",
            uid: data.uid,
        };
        // console.log(messageData);
        const topic = "comments_" + post.category;
        // send push notification to topics
        const sendToTopicRes = await admin.messaging().send(messaging_1.Messaging.topicPayload(topic, messageData));
        // get comment ancestors
        const ancestorsUid = await this.getAncestorsUid(id, data.uid);
        // add the post uid if the comment author is not the post author
        if (post.uid != data.uid && !ancestorsUid.includes(post.uid)) {
            ancestorsUid.push(post.uid);
        }
        // Don't send the same message twice to topic subscribers
        const userUids = await messaging_1.Messaging.getUidsWithoutSubscription(ancestorsUid.join(","), "topic/forum/" + topic);
        // get uids with user setting commentNotification is set.
        const commentNotifyeesUids = await messaging_1.Messaging.getUidsWithSubscription(userUids.join(","), messaging_1.Messaging.commentNotificationField);
        const tokens = await messaging_1.Messaging.getTokensFromUids(commentNotifyeesUids.join(","));
        // console.log(tokens);
        const sendToTokenRes = await messaging_1.Messaging.sendingMessageToTokens(tokens, messaging_1.Messaging.preMessagePayload(messageData));
        return {
            topicResponse: sendToTopicRes,
            tokenResponse: sendToTokenRes,
        };
    }
    // get comment ancestor by getting parent comment until it reach the root comment
    // return the uids of the author
    static async getAncestorsUid(id, authorUid) {
        const c = await ref_1.Ref.commentDoc(id).get();
        let comment = c.data();
        const uids = [];
        while (comment.postId != comment.parentId) {
            const com = await ref_1.Ref.commentDoc(comment.parentId).get();
            if (!com.exists)
                continue;
            comment = com.data();
            if (comment.uid == authorUid)
                continue; // skip the author's uid.
            uids.push(comment.uid);
        }
        return uids.filter((v, i, a) => a.indexOf(v) === i); // remove duplicate
    }
}
exports.Comment = Comment;
//# sourceMappingURL=comment.js.map