// import * as admin from "firebase-admin";
import { Ref } from "./ref";
// import { Utils } from "./utils";

export class PushMessaging {
  static async getTokensFromUids(uids: any) {
    let _uids: Array<any>;
    if (typeof uids == "string") {
      _uids = uids.split(",");
    } else {
      _uids = uids;
    }

    const _tokens = [];
    const getTokensPromise = [];
    for (let u of _uids) {
      getTokensPromise.push(
        Ref.messageTokens.orderByChild("uid").equalTo(u).get()
      );
    }

    const result = await Promise.all(getTokensPromise);
    for (let i in result) {
      if (!result[i]) continue;
      const tokens = result[i].val();
      if (!tokens) continue;
      for (const token in tokens) {
        if (!token) continue;
        _tokens.push(token);
      }
    }

    return _tokens;
  }

  static async getTopicSubscriber(uids: any, topic: string) {
    let _uids: Array<any>;
    if (typeof uids == "string") {
      _uids = uids.split(",");
    } else {
      _uids = uids;
    }

    const re = [];
    const getTopicsPromise = [];
    for (let uid of _uids) {
      getTopicsPromise.push(Ref.userSetting(uid, "topic").get());
    }
    const result = await Promise.all(getTopicsPromise);

    for (let i in result) {
      if (!result[i]) continue;
      const subscriptions = result[i].val();
      // / Get user who subscribe to topic
      if (subscriptions && subscriptions[topic] == false) {
        // skip only if user intentionally off the topic
      } else {
        re.push(_uids[i]);
      }
    }
    return re;
  }
}
