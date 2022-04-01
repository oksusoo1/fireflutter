// import * as admin from "firebase-admin";
import { messaging } from "firebase-admin";
import { MessagePayload } from "../interfaces/messaging.interface";
import { Ref } from "./ref";
import { Utils } from "./utils";
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
   *
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
   *
   * @param uids array of user uid
   * @returns array of tokens
   */
  static async getTokensFromUids(uids: string) {
    const promises: Promise<string[]>[] = [];
    uids.split(",").forEach((uid) => promises.push(this.getTokens(uid)));
    return (await Promise.all(promises)).flat();
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
  static async userHasSusbscription(uid: string, topic: string): Promise<boolean> {
    // / Get all the topics of the user
    const snapshot = await Ref.userSetting(uid, "topic").get();
    if (snapshot.exists() === false) return false;
    const val = snapshot.val();
    return val && val[topic];
  }

  /**
   * Returns true if the user turn off manually the subscription.
   * @param uid uid of a suer
   * @param topic topic
   * @returns Promise<boolean>
   */
  static async userHasSusbscriptionOff(uid: string, topic: string): Promise<boolean> {
    // / Get all the topics of the user
    const snapshot = await Ref.userSetting(uid, "topic").get();
    if (snapshot.exists() === false) return false;
    const val = snapshot.val();
    return val && !val[topic];
  }

  /**
   * Return uids of the user didnt turn off their subscription
   * Note* user without topic info will also be included.
   * @param uids
   * @param topic
   * @returns
   */
  static async removeUserHasSubscriptionOff(uids: string, topic: string) {
    const _uids = uids.split(",");
    const promises: Promise<boolean>[] = [];

    _uids.forEach((uid) => promises.push(this.userHasSusbscriptionOff(uid, topic)));

    const re = [];
    const results = await Promise.all(promises);

    // dont add user who has turn off subscription
    for (const i in results) {
      if (!results[i]) re.push(_uids[i]);
    }
    return re;
  }

  static topicPayload(topic: string, query: any): messaging.TopicMessage {
    const payload = this.preMessagePayload(query);
    payload["topic"] = "/topics/" + topic;
    return payload as messaging.TopicMessage;
  }

  static preMessagePayload(query: any) {
    const res: MessagePayload = {
      data: {
        id: query.postId ? query.postId : query.id ? query.id : "",
        type: query.type ? query.type : "",
        senderUid: query.senderUid ? query.senderUid : query.uid ? query.uid : "",
        badge: query.badge ? query.badge : "",
      },
      notification: {
        title: query.title ? query.title : "",
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
      res.notification.body = Utils.removeHtmlTags(res.notification.body) ?? "";
      res.notification.body = Utils.decodeHTMLEntities(res.notification.body) ?? "";
      res.notification.body = res.notification.body.substring(0, 255);
    }

    if (query.badge != null) {
      res.apns.payload.aps["badge"] = parseInt(query.badge);
    }

    return res;
  }
}
