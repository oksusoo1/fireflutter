// import * as admin from "firebase-admin";
import { Ref } from "./ref";
// import { Utils } from "./utils";

export class Messaging {
  /**
   * Creates a token document with uid.
   *
   * @param uid user uid
   * @param token token of push message
   * @returns Promise of any
   */
  static async updateToken(uid: string, token: string): Promise<any> {
    return Ref.messageTokens.child(token).set({ uid: uid });
  }

  /**
   * Returns tokens of a user.
   * @param uid user uid
   * @returns array of tokens
   */
  static async getTokens(uid: string): Promise<string[]> {
    const snapshot = await Ref.messageTokens.orderByChild("uid").equalTo(uid).get();
    const val = snapshot.val();
    return Object.keys(val);
  }

  /**
   * Returns tokens of multiple users.
   * @param uids array of user uid
   * @returns array of tokens
   */
  static async getTokensFromUids(uids: string) {
    const promises: Promise<string[]>[] = [];
    uids.split(",").forEach((uid, i, arr) => promises.push(this.getTokens(uid)));
    return (await Promise.all(promises)).flat();
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
    for (const uid of _uids) {
      getTopicsPromise.push(Ref.userSetting(uid, "topic").get());
    }
    const result = await Promise.all(getTopicsPromise);

    for (const i in result) {
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
