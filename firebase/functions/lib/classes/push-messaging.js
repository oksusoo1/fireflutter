"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PushMessaging = void 0;
// import * as admin from "firebase-admin";
const ref_1 = require("./ref");
// import { Utils } from "./utils";
class PushMessaging {
    static async getTokensFromUids(uids) {
        let _uids;
        if (typeof uids == "string") {
            _uids = uids.split(",");
        }
        else {
            _uids = uids;
        }
        const _tokens = [];
        const getTokensPromise = [];
        for (const u of _uids) {
            getTokensPromise.push(ref_1.Ref.messageTokens.orderByChild("uid").equalTo(u).get());
        }
        const result = await Promise.all(getTokensPromise);
        for (const i in result) {
            if (!result[i])
                continue;
            const tokens = result[i].val();
            if (!tokens)
                continue;
            for (const token in tokens) {
                if (!token)
                    continue;
                _tokens.push(token);
            }
        }
        return _tokens;
    }
    static async getTopicSubscriber(uids, topic) {
        let _uids;
        if (typeof uids == "string") {
            _uids = uids.split(",");
        }
        else {
            _uids = uids;
        }
        const re = [];
        const getTopicsPromise = [];
        for (const uid of _uids) {
            getTopicsPromise.push(ref_1.Ref.userSetting(uid, "topic").get());
        }
        const result = await Promise.all(getTopicsPromise);
        for (const i in result) {
            if (!result[i])
                continue;
            const subscriptions = result[i].val();
            // / Get user who subscribe to topic
            if (subscriptions && subscriptions[topic] == false) {
                // skip only if user intentionally off the topic
            }
            else {
                re.push(_uids[i]);
            }
        }
        return re;
    }
}
exports.PushMessaging = PushMessaging;
//# sourceMappingURL=push-messaging.js.map