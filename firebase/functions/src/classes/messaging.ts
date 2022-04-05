import * as admin from "firebase-admin";
import { messaging } from "firebase-admin";
import { MessagePayload } from "../interfaces/messaging.interface";
import { Ref } from "./ref";
import { Utils } from "./utils";

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

  // check the uids if they are subscribe to topic and also want to get notification under their post/comment
  /**
   * Get ancestors who subscribed to 'comment notification' but removing those who subscribed to the topic.
   * @param {*} uids ancestors
   * @param {*} topic topic
   * @returns UIDs of ancestors.
   */
  static async getCommentNotifyeeWithoutTopicSubscriber(uids: string, topic: string) {
    const _uids = uids.split(",");
    const promises: Promise<boolean>[] = [];
    _uids.forEach((uid) => promises.push(this.userHasSusbscription(uid, topic)));
    const result = await Promise.all(promises);
    const re = [];
    for (const i in result) {
      // / Get anscestors who subscribed to 'comment notification' and didn't subscribe to the topic.
      if (result[i]) {
        // subscribed to topic, dont send message via token.
      } else {
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
    const results = await Promise.all(promises);

    const re = [];
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

  static async sendingMessageToTokens(
    tokens: Array<string>,
    payload: MessagePayload
  ): Promise<{
    success: number;
    error: number;
  }> {
    if (tokens.length == 0) return { success: 0, error: 0 };

    // / sendMulticast supports 500 token per batch only.
    const chunks = Utils.chunk(tokens, 500);

    const sendToDevicePromise = [];
    for (const c of chunks) {
      // Send notifications to all tokens.
      const newPayload: messaging.MulticastMessage = Object.assign({ tokens: c }, payload as any);
      sendToDevicePromise.push(admin.messaging().sendMulticast(newPayload));
    }
    const sendDevice = await Promise.all(sendToDevicePromise);

    const tokensToRemove: Promise<any>[] = [];
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
          if (
            error.code === "messaging/invalid-registration-token" ||
            error.code === "messaging/registration-token-not-registered" ||
            error.code === "messaging/invalid-argument"
          ) {
            tokensToRemove.push(Ref.messageTokens.child(chunks[i][index]).remove());
          }
        }
      });
    });
    await Promise.all(tokensToRemove);
    return { success: successCount, error: errorCount };
  }

  static async sendMessageToTopic(query: any) {
    const payload = this.topicPayload(query.topic, query);
    try {
      const res = await admin.messaging().send(payload);
      return { code: "success", result: res };
    } catch (e) {
      return { code: "error", message: e };
    }
  }

  static async sendMessageToTokens(query: any) {
    const payload = this.preMessagePayload(query);

    //

    // check if token is empty throw error
    try {
      const res = await this.sendingMessageToTokens(query.tokens.split(","), payload);
      return { code: "success", result: res };
    } catch (e) {
      return { code: "error", message: e };
    }
  }
  /**
   * if subscription exist then remove user who turned of the subscription.
   */
  static async sendMessageToUsers(query: any) {
    const payload = this.preMessagePayload(query);
    let uids: string;
    if (query.subscription) {
      uids = (await this.removeUserHasSubscriptionOff(query.uids, query.subscription)).join(",");
    } else {
      uids = query.uids;
    }
    const tokens = await this.getTokensFromUids(uids);
    try {
      const res = await this.sendingMessageToTokens(tokens, payload);
      return { code: "success", result: res };
    } catch (e) {
      return { code: "error", message: e };
    }
  }

  static async getTopicSubscriber(uids: string, topic: string): Promise<string[]> {
    const _uids = uids.split(",");
    const promises: Promise<boolean>[] = [];
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

  static async subscribeToTopic(tokens: string, topic: string): Promise<messaging.MessagingTopicManagementResponse> {
    return admin.messaging().subscribeToTopic(tokens, topic);
  }
}
