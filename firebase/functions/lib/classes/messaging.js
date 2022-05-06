"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Messaging = void 0;
const admin = require("firebase-admin");
const defines_1 = require("../defines");
const ref_1 = require("./ref");
const utils_1 = require("./utils");
const axios_1 = require("axios");
const fireflutter_config_1 = require("../fireflutter.config");
const category_1 = require("./category");
class Messaging {
    /**
     * Creates(or updates) a token document with uid and do `token-update` process as decribed in README.md.
     *
     * @param data - data.uid is the user uid, data.token is the token of push message.
     *
     * @returns Promise of any
     */
    static async updateToken(data) {
        await this.setToken(data);
        await this.removeInvalidTokens(data.uid);
        await this.unsubscribeAllTopicOfToken(data.token);
        await this.resubscribeAllUserTopics(data.uid);
    }
    /**
     *
     * @param data
     *  uid - user id
     *  token - device token or browser token
     *
     * @returns tokens ref
     */
    static async setToken(data) {
        if (data.uid == null || data.uid == "")
            throw defines_1.ERROR_EMPTY_UID;
        if (data.token == null || data.token == "")
            throw defines_1.ERROR_EMPTY_TOKEN;
        await ref_1.Ref.messageTokens.child(data.token).set({ uid: data.uid });
        return this.getToken(data.token);
    }
    /**
     * Returns the token record
     * @param token
     * @returns
     */
    static async getToken(token) {
        const snapshot = await ref_1.Ref.token(token).get();
        if (snapshot.exists()) {
            const data = snapshot.val();
            data.token = snapshot.key;
            return data;
        }
        else {
            return null;
        }
    }
    /**
     *
     * @param data
     * @returns SubscriptionResponse
     *  topic - topic from request
     *  tokens - user tokens
     *  failureTokens - tokens with failure reason
     *  successCount - number of subscribe success
     *  failureCount - number of failed subscription
     *
     */
    static async subscribeToTopic(data) {
        var _a, _b;
        // turn on topic user-settings/{uid}/topic/type(folderName)/
        await this.topicOn(data);
        // get user tokens
        const tokens = await this.getTokens(data.uid);
        // if user has no token then return;
        if (tokens.length == 0) {
            return {
                topic: data.topic,
                tokens: tokens,
                failureTokens: {},
                successCount: 0,
                failureCount: 0,
            };
        }
        // subscribe user tokens to topic
        const res = await admin
            .messaging()
            .subscribeToTopic(tokens, data.topic);
        // remove invalid tokens if any
        const failureTokens = await this.removeInvalidTokensFromResponse(tokens, res);
        // return failuretokens tokens with failure reason and success and failure count
        return {
            topic: data.topic,
            tokens: tokens,
            failureTokens: failureTokens,
            successCount: (_a = res === null || res === void 0 ? void 0 : res.successCount) !== null && _a !== void 0 ? _a : 0,
            failureCount: (_b = res === null || res === void 0 ? void 0 : res.failureCount) !== null && _b !== void 0 ? _b : 0,
        };
    }
    /**
     *
     * @param data
     * @returns SubscriptionResponse
     *  topic - topic from request
     *  tokens - user tokens
     *  failureTokens - tokens with failure reason
     *  successCount - number of unsubscribe success
     *  failureCount - number of failed unsubscription
     *
     */
    static async unsubscribeToTopic(data) {
        var _a, _b;
        // turn off topic user-settings/{uid}/topic/type(folderName)/
        await this.topicOff(data);
        // get user tokens
        const tokens = await this.getTokens(data.uid);
        // return if user has no tokens
        if (tokens.length == 0) {
            return {
                topic: data.topic,
                tokens: tokens,
                failureTokens: {},
                successCount: 0,
                failureCount: 0,
            };
        }
        // unsubscribe user tokens to topic
        const res = await admin
            .messaging()
            .unsubscribeFromTopic(tokens, data.topic);
        // remove invalid tokens if any
        const failureTokens = await this.removeInvalidTokensFromResponse(tokens, res);
        // return failuretokens tokens with failure reason and success and failure count
        return {
            topic: data.topic,
            tokens: tokens,
            failureTokens: failureTokens,
            successCount: (_a = res === null || res === void 0 ? void 0 : res.successCount) !== null && _a !== void 0 ? _a : 0,
            failureCount: (_b = res === null || res === void 0 ? void 0 : res.failureCount) !== null && _b !== void 0 ? _b : 0,
        };
    }
    /**
     * Check if the data is set and not empty
     * @param data
     *  uid - user id
     *  topic - topic to subscribe
     *  type - folderName
     */
    static checkTopicData(data) {
        if (!data.uid)
            throw defines_1.ERROR_EMPTY_UID;
        if (!data.topic)
            throw defines_1.ERROR_EMPTY_TOPIC;
        if (!data.type)
            throw defines_1.ERROR_EMPTY_TOPIC_TYPE;
    }
    /**
     * Toggle the user topic true or false
     * @param data
     * @returns
     */
    static async topicToggle(data) {
        this.checkTopicData(data);
        const topic = await this.getTopic(data);
        if (topic != null && topic[data.topic]) {
            return this.topicOff(data);
        }
        else {
            return this.topicOn(data);
        }
    }
    /**
     * Set user-settings/{uid}/topic/type(folderName)/
     * {[topic]: true}
     *
     * @param data
     * @returns
     */
    static async topicOn(data) {
        this.checkTopicData(data);
        await ref_1.Ref.userSettingTopic(data.uid)
            .child(data.type)
            .update({
            [data.topic]: true,
        });
        return this.getTopics(data.uid, data.type);
    }
    /**
     * Set user-settings/{uid}/topic/type(folderName)/
     * {[topic]: false}
     *
     * @param data
     * @returns
     */
    static async topicOff(data) {
        this.checkTopicData(data);
        await ref_1.Ref.userSettingTopic(data.uid)
            .child(data.type)
            .update({
            [data.topic]: false,
        });
        return this.getTopics(data.uid, data.type);
    }
    static async getTopic(data) {
        const snapshot = await ref_1.Ref.userSettingTopic(data.uid).child(data.type).child(data.topic).get();
        if (snapshot.exists()) {
            const val = snapshot.val();
            return { [data.topic]: val };
        }
        return null;
    }
    /**
     * Returns the topics from type(foldersName)
     * @param uid
     * @param type
     * @returns {[topic]: boolean} || null
     */
    static async getTopics(uid, type) {
        const snapshot = await ref_1.Ref.userSettingTopic(uid).child(type).get();
        if (snapshot.exists()) {
            const val = snapshot.val();
            return val;
        }
        return null;
    }
    /**
     * Removes invalid tokens.
     *
     * It subscribes the default topic on every token update on app starts(or user logs in).
     * We found it is more efficient than removing invalid token on every subscription(or unsubscription) or sending messages.
     *
     *
     * @param uid user uid
     * @returns
     */
    static async removeInvalidTokens(uid) {
        // get all user tokens
        const tokens = await this.getTokens(uid);
        // subscribe to default
        const res = await admin.messaging().subscribeToTopic(tokens, this.defaultTopic);
        // remove all invalid tokens base from the response
        await this.removeInvalidTokensFromResponse(tokens, res);
        return res;
    }
    /**
     * Remove invalid tokens.
     *
     * This may be used to remove invalid tokens after sending messages or (un)subscribing topic.
     *
     * @param tokens token list that matches the `res` of sending massage or subscribing(unsubscribing) topics.
     * @param res response(result) of sending messages or subscribing topic.
     * @returns Map of result.
     */
    static async removeInvalidTokensFromResponse(tokens, res) {
        if (res.failureCount == 0)
            return {};
        const failureToken = {};
        const tokensToRemove = [];
        res.errors.forEach((e) => {
            if (e.error) {
                if (this.isInvalidTokenErrorCode(e.error.code)) {
                    tokensToRemove.push(ref_1.Ref.messageTokens.child(tokens[e.index]).remove());
                    failureToken[tokens[e.index]] = e.error.code;
                }
            }
        });
        await Promise.all(tokensToRemove);
        return failureToken;
    }
    static isInvalidTokenErrorCode(code) {
        if (code === "messaging/invalid-registration-token" ||
            code === "messaging/registration-token-not-registered" ||
            code === "messaging/invalid-argument") {
            return true;
        }
        return false;
    }
    /**
     * This unsubscribe all the topics (including other user's topics) of the token.
     * See README.md for details.
     * @returns array of topic as string
     */
    static async unsubscribeAllTopicOfToken(token) {
        // get all topics topics
        const topics = await this.getTokenTopics(token);
        if (topics.length == 0)
            return [];
        const promises = [];
        const res = [];
        topics.forEach((topic) => {
            if (topic == this.defaultTopic)
                return;
            res.push(topic);
            promises.push(admin.messaging().unsubscribeFromTopic(token, topic));
        });
        await Promise.all(promises);
        return res;
    }
    /**
     * @reference https://stackoverflow.com/questions/38212123/unsubscribe-from-all-topics-at-once-from-firebase-messaging
     * @param token
     * @returns string[] of topics or empty [] if error or no topics
     */
    static async getTokenTopics(token) {
        const url = "https://iid.googleapis.com/iid/info/" + token;
        const key = "key = " + fireflutter_config_1.config.serverKey;
        try {
            const res = await axios_1.default.get(url, {
                params: { details: true },
                headers: { Authorization: key },
            });
            // console.log(res);
            if (res.data.rel == null)
                return [];
            if (res.data.rel.topics == null)
                return [];
            return Object.keys(res.data.rel.topics);
        }
        catch (e) {
            // console.log("=======================");
            // console.log((e as any).response.data.error);
            return [];
        }
    }
    /**
     *
     */
    static async resubscribeAllUserTopics(uid) {
        // subscribe to user forum topics
        const forum = await this.subscribeUserToSettingTopics(uid, "forum");
        // subscribe to user job topics
        // await this.subscribeUserToSettingTopics(uid, "job" );
        return {
            forum: forum,
        };
    }
    /**
     *
     * @param uid
     * @param type The child topic folder name under `/user-settings/<uid>/topics/<folder-name>`.
     * @returns
     */
    static async subscribeUserToSettingTopics(uid, type) {
        const userSubs = await this.getSettingSubscription(uid, type);
        if (!userSubs)
            return null;
        const subscribePromises = [];
        Object.keys(userSubs).forEach((topic) => {
            if (userSubs[topic]) {
                subscribePromises.push(this.subscribeToTopic({ uid: uid, topic: topic, type: type }));
            }
        });
        const res = await Promise.all(subscribePromises);
        return res;
    }
    /**
     * Returns tokens of a user.
     *
     * @param uid user uid
     * @returns array of tokens
     */
    static async getTokens(uid) {
        const snapshot = await ref_1.Ref.messageTokens.orderByChild("uid").equalTo(uid).get();
        if (!snapshot.exists())
            return [];
        const val = snapshot.val();
        return Object.keys(val);
    }
    /**
     * Returns tokens of multiple users.
     *
     * @param uids array of user uid
     * @returns array of tokens
     */
    static async getTokensFromUids(uids) {
        const promises = [];
        uids.split(",").forEach((uid) => promises.push(this.getTokens(uid)));
        return (await Promise.all(promises)).flat();
    }
    // check the uids if they are subscribe to topic and also want to get notification under their post/comment
    /**
     * Get ancestors who subscribed to 'comment notification' but removing those who subscribed to the topic.
     * @param {*} uids ancestors
     * @param {*} topic topic
     * @returns UIDs of ancestors.
     */
    static async getCommentNotifyeeWithoutTopicSubscriber(uids, topic) {
        const _uids = uids.split(",");
        const promises = [];
        _uids.forEach((uid) => promises.push(this.userHasSusbscription(uid, topic)));
        const result = await Promise.all(promises);
        const re = [];
        for (const i in result) {
            // / Get anscestors who subscribed to 'comment notification' and didn't subscribe to the topic.
            if (result[i]) {
                // subscribed to topic, dont send message via token.
            }
            else {
                re.push(_uids[i]);
            }
        }
        return re;
    }
    // /**
    //  * Return true if the user didn't subscribe the topic.
    //  * @param uid uid of a user
    //  * @param topic topic
    //  * @returns Promise<boolean>
    //  */
    // static async isUserSubscriptionOff(
    //   uid: string,
    //   topic: string
    // ): Promise<boolean> {
    //   return !this.userHasSusbscription(uid, topic);
    // }
    /**
     * Returns true if the user subscribed the topic.
     * @param uid uid of a suer
     * @param topic topic
     * @returns Promise<boolean>
     */
    static async userHasSusbscription(uid, topic) {
        // / Get all the topics of the user
        const snapshot = await ref_1.Ref.userSetting(uid, "topic").get();
        if (snapshot.exists() === false)
            return false;
        const val = snapshot.val();
        if (!val)
            return false;
        return !!val[topic];
    }
    /**
     * Returns true if the user turn off manually the subscription.
     * @param uid uid of a suer
     * @param topic topic
     * @returns Promise<boolean>
     */
    static async userHasSusbscriptionOff(uid, topic) {
        // / Get all the topics of the user
        const snapshot = await ref_1.Ref.userSetting(uid, "topic").get();
        console.log(snapshot.exists());
        if (snapshot.exists() === false)
            return false;
        const val = snapshot.val();
        if (!val)
            return false;
        // If it's undefined, then user didn't subscribed ever since.
        if (typeof val[topic] === undefined)
            return false;
        // If it's false, then it is disabled manually by the user.
        if (val[topic] === false)
            return true;
        // If it's true, then the topic is subscribed.
        return false;
    }
    /**
     * Return uids of the user didnt turn off their subscription
     * Note* user without topic info will also be included.
     * @param uids
     * @param topic
     * @returns
     */
    static async removeUserHasSubscriptionOff(uids, topic) {
        const _uids = uids.split(",");
        const promises = [];
        let results = [];
        _uids.forEach((uid) => promises.push(this.userHasSusbscriptionOff(uid, topic)));
        results = await Promise.all(promises);
        const re = [];
        // dont add user who has turn off subscription
        for (const i in results) {
            if (!results[i])
                re.push(_uids[i]);
        }
        return re;
    }
    static topicPayload(topic, query) {
        const payload = this.preMessagePayload(query);
        payload["topic"] = "/topics/" + topic;
        return payload;
    }
    static preMessagePayload(query) {
        var _a, _b, _c, _d, _e, _f, _g;
        if (!query.title && !query.body)
            throw defines_1.ERROR_TITLE_AND_BODY_CANT_BE_BOTH_EMPTY;
        const res = {
            data: {
                id: query.postId ? query.postId : query.id ? query.id : "",
                type: (_a = query.type) !== null && _a !== void 0 ? _a : "",
                senderUid: (_c = (_b = query.senderUid) !== null && _b !== void 0 ? _b : query.uid) !== null && _c !== void 0 ? _c : "",
                badge: (_d = query.badge) !== null && _d !== void 0 ? _d : "",
            },
            notification: {
                title: (_e = query.title) !== null && _e !== void 0 ? _e : "",
                body: query.body ? query.body : query.content ? query.content : "",
            },
            android: {
                notification: {
                    channelId: "PUSH_NOTIFICATION",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK",
                    sound: "default_sound.wav",
                },
            },
            apns: {
                payload: {
                    aps: {
                        sound: "default_sound.wav",
                    },
                },
            },
        };
        if (res.notification.title != "" && res.notification.title.length > 64) {
            res.notification.title = res.notification.title.substring(0, 64);
        }
        if (res.notification.body != "") {
            res.notification.body = (_f = utils_1.Utils.removeHtmlTags(res.notification.body)) !== null && _f !== void 0 ? _f : "";
            res.notification.body = (_g = utils_1.Utils.decodeHTMLEntities(res.notification.body)) !== null && _g !== void 0 ? _g : "";
            if (res.notification.body.length > 255) {
                res.notification.body = res.notification.body.substring(0, 255);
            }
        }
        if (query.badge != null) {
            res.apns.payload.aps["badge"] = parseInt(query.badge);
        }
        return res;
    }
    static async sendingMessageToTokens(tokens, payload) {
        if (tokens.length == 0)
            return { success: 0, error: 0 };
        // / sendMulticast supports 500 token per batch only.
        const chunks = utils_1.Utils.chunk(tokens, 500);
        const sendToDevicePromise = [];
        for (const c of chunks) {
            // Send notifications to all tokens.
            const newPayload = Object.assign({ tokens: c }, payload);
            sendToDevicePromise.push(admin.messaging().sendMulticast(newPayload));
        }
        const sendDevice = await Promise.all(sendToDevicePromise);
        const tokensToRemove = [];
        let successCount = 0;
        let errorCount = 0;
        sendDevice.forEach((res, i) => {
            successCount += res.successCount;
            errorCount += res.failureCount;
            res.responses.forEach((result, index) => {
                const error = result.error;
                if (error) {
                    // console.log(
                    //     "Failure sending notification to",
                    //     chunks[i][index],
                    //     error,
                    // );
                    // console.log('error.code');
                    // console.log(error.code);
                    // Cleanup the tokens who are not registered anymore.
                    if (this.isInvalidTokenErrorCode(error.code)) {
                        tokensToRemove.push(ref_1.Ref.messageTokens.child(chunks[i][index]).remove());
                    }
                }
            });
        });
        await Promise.all(tokensToRemove);
        return { success: successCount, error: errorCount };
    }
    static async sendMessageToTopic(query) {
        if (!query.topic)
            throw defines_1.ERROR_EMPTY_TOPIC;
        const payload = this.topicPayload(query.topic, query);
        try {
            const res = await admin.messaging().send(payload);
            return { messageId: res };
        }
        catch (e) {
            return { code: "error", message: e.message };
        }
    }
    static async sendMessageToTokens(query) {
        if (!query.tokens)
            throw defines_1.ERROR_EMPTY_TOKENS;
        const payload = this.preMessagePayload(query);
        try {
            const res = await this.sendingMessageToTokens(query.tokens.split(","), payload);
            return res;
        }
        catch (e) {
            return { code: "error", message: e.message };
        }
    }
    /**
     * if subscription exist then remove user who turned of the subscription.
     */
    static async sendMessageToUsers(query) {
        if (!query.uids)
            throw defines_1.ERROR_EMPTY_UIDS;
        const payload = this.preMessagePayload(query);
        let uids;
        if (query.subscription) {
            uids = (await this.removeUserHasSubscriptionOff(query.uids, query.subscription)).join(",");
        }
        else {
            uids = query.uids;
        }
        if (!uids)
            return { success: 0, error: 0 };
        const tokens = await this.getTokensFromUids(uids);
        try {
            const res = await this.sendingMessageToTokens(tokens, payload);
            return res;
        }
        catch (e) {
            return { code: "error", message: e.message };
        }
    }
    static async getTopicSubscriber(uids, topic) {
        const _uids = uids.split(",");
        const promises = [];
        _uids.forEach((uid) => promises.push(this.userHasSusbscription(uid, topic)));
        const result = await Promise.all(promises);
        const re = [];
        for (const i in result) {
            // check if user subscribe to topic
            if (result[i]) {
                re.push(_uids[i]);
            }
        }
        return re;
    }
    /**
     * Returns user-settings/{uid}/topic/type that is set to true.
     *
     * @param uid user uid
     * @param type The child topic folder name under `/user-settings/<uid>/topics/<folder-name>`.
     * @returns The documents of topic folder name that have the topic liste with boolean value.
     */
    static async getSettingSubscription(uid, type) {
        const snapshot = await ref_1.Ref.userSettingTopic(uid).child(type).orderByKey().get();
        if (!snapshot.exists())
            return null;
        const val = snapshot.val();
        return val;
    }
    static async enableAllNotification(data) {
        var _a, _b;
        const group = (_a = data.group) !== null && _a !== void 0 ? _a : "community";
        const type = (_b = data.type) !== null && _b !== void 0 ? _b : "forum";
        const cats = await category_1.Category.gets(group);
        const promises = [];
        cats.forEach((cat) => {
            promises.push(Messaging.subscribeToTopic({
                uid: data.uid,
                topic: "posts_" + cat.id,
                type: type,
            }));
            promises.push(Messaging.subscribeToTopic({
                uid: data.uid,
                topic: "comments_" + cat.id,
                type: type,
            }));
        });
        await Promise.all(promises);
        return {
            group: group,
            type: type,
            categories: cats,
        };
    }
    static async disableAllNotification(data) {
        var _a, _b;
        const group = (_a = data.group) !== null && _a !== void 0 ? _a : "community";
        const type = (_b = data.type) !== null && _b !== void 0 ? _b : "forum";
        const cats = await category_1.Category.gets(group);
        const promises = [];
        cats.forEach((cat) => {
            promises.push(Messaging.unsubscribeToTopic({
                uid: data.uid,
                topic: "posts_" + cat.id,
                type: type,
            }));
            promises.push(Messaging.unsubscribeToTopic({
                uid: data.uid,
                topic: "comments_" + cat.id,
                type: type,
            }));
        });
        await Promise.all(promises);
        return {
            group: group,
            type: type,
            categories: cats,
        };
    }
}
exports.Messaging = Messaging;
Messaging.defaultTopic = "defaultTopic";
//# sourceMappingURL=messaging.js.map