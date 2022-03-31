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
    const snapshot = await Ref.messageTokens
      .orderByChild("uid")
      .equalTo(uid)
      .get();
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
    uids
      .split(",")
      .forEach((uid, i, arr) => promises.push(this.getTokens(uid)));
    return (await Promise.all(promises)).flat();
  }

  static async isUserSubscriptionOff(
    uid: string,
    subscription: string
  ): Promise<boolean> {
    const snapshot = await Ref.userSetting(uid, "topic").get();
    if (!snapshot.exists()) return true;
    const val = snapshot.val();
    if (val && val[subscription] == false) {
      return false;
    } else {
      return true;
    }
  }

  static async getTopicSubscriber(uids: string, subscription: string) {
    const _uids = uids.split(",");
    const promises: Promise<boolean>[] = [];
    _uids.forEach((uid) =>
      promises.push(this.isUserSubscriptionOff(uid, subscription))
    );

    const re = [];
    const result = await Promise.all(promises);

    for (const i in result) {
      if (result[i]) re.push(_uids[i]);
    }
    return re;
  }
}
