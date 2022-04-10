"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Messaging = void 0;
const admin = require("firebase-admin");
const defines_1 = require("../defines");
const ref_1 = require("./ref");
const utils_1 = require("./utils");
class Messaging {
    /**
     * Creates a token document with uid.
     *
     * @param uid user uid
     * @param token token of push message
     * @returns Promise of any
     */
    static async updateToken(uid, token) {
        return ref_1.Ref.messageTokens.child(token).set({ uid: uid });
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
        if (res.notification.body != "") {
            res.notification.body = (_f = utils_1.Utils.removeHtmlTags(res.notification.body)) !== null && _f !== void 0 ? _f : "";
            res.notification.body = (_g = utils_1.Utils.decodeHTMLEntities(res.notification.body)) !== null && _g !== void 0 ? _g : "";
            res.notification.body = res.notification.body.substring(0, 255);
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
                    if (error.code === "messaging/invalid-registration-token" ||
                        error.code === "messaging/registration-token-not-registered" ||
                        error.code === "messaging/invalid-argument") {
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
    static async subscribeToTopic(tokens, topic) {
        return admin.messaging().subscribeToTopic(tokens, topic);
    }
}
exports.Messaging = Messaging;
//# sourceMappingURL=messaging.js.map