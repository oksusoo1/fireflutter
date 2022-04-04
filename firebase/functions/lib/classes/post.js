"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Post = void 0;
const admin = require("firebase-admin");
const dayjs = require("dayjs");
const dayOfYear = require("dayjs/plugin/dayOfYear");
const weekOfYear = require("dayjs/plugin/weekOfYear");
dayjs.extend(dayOfYear);
dayjs.extend(weekOfYear);
const forum_interface_1 = require("../interfaces/forum.interface");
const ref_1 = require("./ref");
const defines_1 = require("../defines");
const messaging_1 = require("./messaging");
class Post {
    /**
     *
     * @param data post doc data to be created
     * @returns post doc data after create. Note that, it will contain post id.
     */
    static async create(data) {
        // check up
        if (!data.uid)
            throw defines_1.ERROR_EMPTY_UID;
        if (!data.category)
            throw defines_1.ERROR_EMPTY_CATEGORY;
        // get all the data from client.
        const doc = data;
        delete doc.password;
        // default data
        doc.hasPhoto = !!doc.files;
        doc.deleted = false;
        doc.noOfComments = 0;
        doc.year = dayjs().year();
        doc.month = dayjs().month() + 1;
        doc.day = dayjs().date();
        doc.dayOfYear = dayjs().dayOfYear();
        doc.week = dayjs().week();
        doc.createdAt = admin.firestore.FieldValue.serverTimestamp();
        doc.updatedAt = admin.firestore.FieldValue.serverTimestamp();
        // create post
        const ref = await ref_1.Ref.postCol.add(doc);
        // return the document object of newly created post.
        const snapshot = await ref.get();
        if (snapshot.exists) {
            return new forum_interface_1.PostDocument().fromDocument(snapshot.data(), ref.id);
        }
        else {
            return null;
        }
    }
    static async get(id) {
        const snapshot = await ref_1.Ref.postDoc(id).get();
        if (snapshot.exists) {
            // return snapshot.data() as PostDocument;
            const data = snapshot.data();
            if (data)
                return new forum_interface_1.PostDocument().fromDocument(data, id);
        }
        return null;
    }
    static async sendMessageOnPostCreate(data) {
        const category = data.category;
        const payload = messaging_1.Messaging.topicPayload("posts_" + category, {
            title: data.title ? data.title : "",
            body: data.content ? data.content : "",
            postId: data.id,
            type: "post",
            uid: data.uid,
        });
        return admin.messaging().send(payload);
    }
    static async sendMessageOnCommentCreate(data) {
        const post = await this.get(data.postId);
        if (!post)
            return null;
        const messageData = {
            title: "New Comment: ",
            body: post.content,
            postId: data.postId,
            type: "post",
            uid: data.uid,
        };
        // console.log(messageData);
        const topic = "comments_" + post.category;
        // send push notification to topics
        const sendToTopicRes = await admin.messaging().send(messaging_1.Messaging.topicPayload(topic, messageData));
        console.log(sendToTopicRes);
        // get comment ancestors
        const ancestorsUid = await Post.getCommentAncestors(data.id, data.uid);
        console.log("ancestorsUid");
        console.log(ancestorsUid);
        // add the post uid if the comment author is not the post author
        if (post.uid != data.uid && !ancestorsUid.includes(post.uid)) {
            ancestorsUid.push(post.uid);
        }
        // Don't send the same message twice to topic subscribers and comment notifyees.
        const userUids = await messaging_1.Messaging.getCommentNotifyeeWithoutTopicSubscriber(ancestorsUid.join(","), topic);
        console.log("getCommentNotifyeeWithoutTopicSubscriber");
        console.log(userUids);
        // get users tokens
        const tokens = await messaging_1.Messaging.getTokensFromUids(userUids.join(","));
        console.log("tokens");
        console.log(tokens);
        const sendToTokenRes = await messaging_1.Messaging.sendingMessageToTokens(tokens, messaging_1.Messaging.preMessagePayload(messageData));
        return {
            topicResponse: sendToTopicRes,
            tokenResponse: sendToTokenRes,
        };
    }
    // get comment ancestor by getting parent comment until it reach the root comment
    // return the uids of the author
    static async getCommentAncestors(id, authorUid) {
        const c = await ref_1.Ref.commentDoc(id).get();
        let comment = new forum_interface_1.CommentDocument().fromDocument(c.data(), id);
        const uids = [];
        while (comment.postId != comment.parentId) {
            const com = await ref_1.Ref.commentDoc(comment.parentId).get();
            if (!com.exists)
                continue;
            comment = new forum_interface_1.CommentDocument().fromDocument(com.data(), comment.parentId);
            if (comment.uid == authorUid)
                continue; // skip the author's uid.
            uids.push(comment.uid);
        }
        return uids.filter((v, i, a) => a.indexOf(v) === i); // remove duplicate
    }
}
exports.Post = Post;
//# sourceMappingURL=post.js.map