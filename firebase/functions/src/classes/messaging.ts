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
    if (!snapshot.exists()) return [];
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
    uids.split(",").forEach((uid) => promises.push(this.getTokens(uid)));
    return (await Promise.all(promises)).flat();
  }

  /**
   * Return true if the user didn't subscribe the topic.
   * @param uid uid of a user
   * @param topic topic
   * @returns Promise<boolean>
   */
  static async isUserSubscriptionOff(uid: string, topic: string): Promise<boolean> {
    return !this.userHasSusbscription(uid, topic);
  }

  /**
   * Returns true if the user subscribed the topic.
   * @param uid uid of a suer
   * @param topic topic
   * @returns Promise<boolean>
   */
  static async userHasSusbscription(uid: string, topic: string): Promise<boolean> {
    /// Get all the topics of the user
    const snapshot = await Ref.userSetting(uid, "topic").get();
    if (snapshot.exists() === false) return false;
    const val = snapshot.val();
    return val && val[topic];
  }

  static async getTopicSubscriber(uids: string, topic: string) {
    const _uids = uids.split(",");
    const promises: Promise<boolean>[] = [];
    _uids.forEach((uid) => promises.push(this.isUserSubscriptionOff(uid, topic)));

    const re = [];
    const results = await Promise.all(promises);

    for (const i in results) {
      if (results[i]) re.push(_uids[i]);
    }
    return re;
  }
}
