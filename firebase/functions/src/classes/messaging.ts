import * as admin from "firebase-admin";
import {
  ERROR_EMPTY_TOKENS,
  ERROR_EMPTY_TOPIC,
  ERROR_EMPTY_UIDS,
  ERROR_TITLE_AND_BODY_CANT_BE_BOTH_EMPTY,
} from "../defines";
import { MessagePayload, TokenDocument } from "../interfaces/messaging.interface";
import { Ref } from "./ref";
import { Utils } from "./utils";

import axios from "axios";

import { config } from "../fireflutter.config";
import { MessagingTopicManagementResponse } from "firebase-admin/lib/messaging/messaging-api";

interface MapStringString {
  [key: string]: string;
}

export class Messaging {
  static defaultTopic = "defaultTopic";

  /**
   * Creates(or updates) a token document with uid and do `token-update` process as decribed in README.md.
   *
   * @param data - data.uid is the user uid, data.token is the token of push message.
   *
   * @returns Promise of any
   */
  static async updateToken(data: TokenDocument): Promise<any> {
    await this.setToken(data);
    await this.removeInvalidTokens(data.uid);
    await this.unsubscribeAllTopicOfToken(data.token);
    await this.resubscribeAllUserTopics(data.uid);
  }

  static async setToken(data: TokenDocument) {
    await Ref.messageTokens.child(data.token).set({ uid: data.uid });
  }

  static async getToken(id: string): Promise<null | TokenDocument> {
    const snapshot = await Ref.token(id).get();
    if (snapshot.exists()) {
      const data = snapshot.val();
      data.token = snapshot.key;
      return data;
    } else {
      return null;
    }
  }

  static async subscribeToTopic(data: { uid: string; topic: string; type: string }): Promise<any> {
    const tokens = await this.getTokens(data.uid);
    if (tokens.length == 0) return null;
    const res = await admin.messaging().subscribeToTopic(tokens, data.topic);
    // console.log(res);
    await Ref.userSettingTopic(data.uid)
      .child(data.type)
      .update({
        [data.topic]: true,
      });
    const failureToken: any = {};
    if (res.failureCount > 0) {
      const tokensToRemove: Promise<any>[] = [];
      res.errors.forEach((e) => {
        if (e.error) {
          if (this.isInvalidTokenErrorCode(e.error.code)) {
            tokensToRemove.push(Ref.messageTokens.child(tokens[e.index]).remove());
            failureToken[tokens[e.index]] = e.error.code;
          }
        }
      });

      await Promise.all(tokensToRemove);
    }
    return {
      successCount: res.successCount,
      failureCount: res.failureCount,
      tokens: tokens,
      failureToken: failureToken,
    };
  }

  static async unsubscribeToTopic(data: {
    uid: string;
    topic: string;
    type: string;
  }): Promise<any> {
    const tokens = await this.getTokens(data.uid);
    if (tokens.length == 0) return null;
    await admin.messaging().unsubscribeFromTopic(tokens, data.topic);
    await Ref.userSettingTopic(data.uid)
      .child(data.type)
      .update({
        [data.topic]: false,
      });
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
  static async removeInvalidTokens(uid: string) {
    // get all user tokens
    const tokens = await this.getTokens(uid);

    // subscribe to default
    const res = await admin.messaging().subscribeToTopic(tokens, this.defaultTopic);

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
  static async removeInvalidTokensFromResponse(
    tokens: Array<string>,
    res: MessagingTopicManagementResponse
  ): Promise<MapStringString> {
    if (res.failureCount == 0) return {};

    const failureToken: MapStringString = {};
    const tokensToRemove: Promise<any>[] = [];
    res.errors.forEach((e) => {
      if (e.error) {
        if (this.isInvalidTokenErrorCode(e.error.code)) {
          tokensToRemove.push(Ref.messageTokens.child(tokens[e.index]).remove());
          failureToken[tokens[e.index]] = e.error.code;
        }
      }
    });
    await Promise.all(tokensToRemove);
    return failureToken;
  }

  static isInvalidTokenErrorCode(code: string) {
    if (
      code === "messaging/invalid-registration-token" ||
      code === "messaging/registration-token-not-registered" ||
      code === "messaging/invalid-argument"
    ) {
      return true;
    }
    return false;
  }

  /**
   * This unsubscribe all the topics (including other user's topics) of the token.
   * See README.md for details.
   *
   */
  static async unsubscribeAllTopicOfToken(token: string) {
    // get all topics topics
    const topics = await this.getTokenTopics(token);
    if (topics.length == 0) return [];

    const promises: any[] = [];
    const res: string[] = [];
    topics.forEach((topic: string) => {
      if (topic == this.defaultTopic) return;
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
  static async getTokenTopics(token: string) {
    const url = "https://iid.googleapis.com/iid/info/" + token;
    const key = "key = " + config.serverKey;

    try {
      const res = await axios.get(url, {
        params: { details: true },
        headers: { Authorization: key },
      });
      // console.log(res);
      if (res.data.rel == null) return [];
      if (res.data.rel.topics == null) return [];
      return Object.keys(res.data.rel.topics);
    } catch (e) {
      // console.log("=======================");
      // console.log((e as any).response.data.error);
      return [];
    }
  }
  /**
   *
   */
  static async resubscribeAllUserTopics(uid: string) {
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
  static async subscribeUserToSettingTopics(uid: string, type: string) {
    const userSubs = await this.getSettingSubscription(uid, type);
    if (!userSubs) return null;
    const subscribePromises: any[] = [];
    Object.keys(userSubs).forEach((topic: any) => {
      if (userSubs[topic]) {
        subscribePromises.push(this.subscribeToTopic({ uid: uid, topic: topic, type: type }));
      }
      //  else {
      //   subscribePromises.push(this.unsubscribeToTopic({ uid: uid, topic: topic, type: type }));
      // }
    });
    const res = await Promise.all(subscribePromises);
    console.log(res);
    return res;
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
    if (!val) return false;
    return !!val[topic];
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
    console.log(snapshot.exists());
    if (snapshot.exists() === false) return false;
    const val = snapshot.val();

    if (!val) return false;
    // If it's undefined, then user didn't subscribed ever since.
    if (typeof val[topic] === undefined) return false;
    // If it's false, then it is disabled manually by the user.
    if (val[topic] === false) return true;
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
  static async removeUserHasSubscriptionOff(uids: string, topic: string) {
    const _uids = uids.split(",");
    const promises: Promise<boolean>[] = [];
    let results: boolean[] = [];
    _uids.forEach((uid) => promises.push(this.userHasSusbscriptionOff(uid, topic)));
    results = await Promise.all(promises);

    const re = [];
    // dont add user who has turn off subscription
    for (const i in results) {
      if (!results[i]) re.push(_uids[i]);
    }
    return re;
  }

  static topicPayload(topic: string, query: any): admin.messaging.TopicMessage {
    const payload = this.preMessagePayload(query);
    payload["topic"] = "/topics/" + topic;
    return payload as admin.messaging.TopicMessage;
  }

  static preMessagePayload(query: any) {
    if (!query.title && !query.body) throw ERROR_TITLE_AND_BODY_CANT_BE_BOTH_EMPTY;
    const res: MessagePayload = {
      data: {
        id: query.postId ? query.postId : query.id ? query.id : "",
        type: query.type ?? "",
        senderUid: query.senderUid ?? query.uid ?? "",
        badge: query.badge ?? "",
      },
      notification: {
        title: query.title ?? "",
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
      res.notification.body = Utils.removeHtmlTags(res.notification.body) ?? "";
      res.notification.body = Utils.decodeHTMLEntities(res.notification.body) ?? "";
      if (res.notification.body.length > 255) {
        res.notification.body = res.notification.body.substring(0, 255);
      }
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
      const newPayload: admin.messaging.MulticastMessage = Object.assign(
        { tokens: c },
        payload as any
      );
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
          if (this.isInvalidTokenErrorCode(error.code)) {
            tokensToRemove.push(Ref.messageTokens.child(chunks[i][index]).remove());
          }
        }
      });
    });
    await Promise.all(tokensToRemove);
    return { success: successCount, error: errorCount };
  }

  static async sendMessageToTopic(query: any) {
    if (!query.topic) throw ERROR_EMPTY_TOPIC;
    const payload = this.topicPayload(query.topic, query);
    try {
      const res = await admin.messaging().send(payload);
      return { messageId: res };
    } catch (e) {
      return { code: "error", message: (e as Error).message };
    }
  }

  static async sendMessageToTokens(query: any) {
    if (!query.tokens) throw ERROR_EMPTY_TOKENS;
    const payload = this.preMessagePayload(query);
    try {
      const res = await this.sendingMessageToTokens(query.tokens.split(","), payload);
      return res;
    } catch (e) {
      return { code: "error", message: (e as Error).message };
    }
  }
  /**
   * if subscription exist then remove user who turned of the subscription.
   */
  static async sendMessageToUsers(query: any) {
    if (!query.uids) throw ERROR_EMPTY_UIDS;
    const payload = this.preMessagePayload(query);
    let uids: string;
    if (query.subscription) {
      uids = (await this.removeUserHasSubscriptionOff(query.uids, query.subscription)).join(",");
    } else {
      uids = query.uids;
    }

    if (!uids) return { success: 0, error: 0 };
    const tokens = await this.getTokensFromUids(uids);
    try {
      const res = await this.sendingMessageToTokens(tokens, payload);
      return res;
    } catch (e) {
      return { code: "error", message: (e as Error).message };
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

  /**
   * Returns user-settings/{uid}/topic/type that is set to true.
   *
   * @param uid user uid
   * @param type The child topic folder name under `/user-settings/<uid>/topics/<folder-name>`.
   * @returns The documents of topic folder name that have the topic liste with boolean value.
   */
  static async getSettingSubscription(uid: string, type: string): Promise<any | null> {
    const snapshot = await Ref.userSettingTopic(uid).child(type).orderByKey().get();
    if (!snapshot.exists()) return null;
    const val = snapshot.val();
    return val;
  }

  // /**
  //  * Returns user forum topics.
  //  *
  //  * @param uid user uid
  //  * @returns array of topic
  //  */
  // static async getForumTopics(uid: string): Promise<string[]> {
  //   const snapshot = await Ref.userSettingForumTopics(uid).get();
  //   if (!snapshot.exists()) return [];
  //   const val = snapshot.val();
  //   return Object.keys(val);
  // }

  // /**
  //  *
  //  * Unsubcribe all topics that
  //  * @param user
  //  * @param uid
  //  * @returns
  //  */
  // static async resubscribeTopics(user: UserDocument, uid: string) {
  //   // get user tokens
  //   const initialTokens = await this.getTokens(uid);
  //   let tokens = initialTokens;
  //   if (tokens.length == 0) return null;

  //   // get user forum topics
  //   const forumTopics = await this.getForumTopics(uid);
  //   if (forumTopics.length == 0) return null;

  //   // get 1 topic first
  //   const topic = forumTopics.splice(0, 1)[0];
  //   // unsubscribe to 1 topic
  //   const res = await admin.messaging().unsubscribeFromTopic(tokens, topic);

  //   // if there is failure remove tokens with invalid status
  //   if (res.failureCount > 0) {
  //     const tokensToRemove: Promise<any>[] = [];
  //     res.errors.forEach((e) => {
  //       if (
  //         e.error.code === "messaging/invalid-registration-token" ||
  //         e.error.code === "messaging/registration-token-not-registered" ||
  //         e.error.code === "messaging/invalid-argument"
  //       ) {
  //         tokensToRemove.push(Ref.messageTokens.child(tokens[e.index]).remove());
  //       }
  //     });
  //     await Promise.all(tokensToRemove);

  //     // get again the remaining tokens after removing invalid tokens
  //     tokens = await this.getTokens(uid);
  //     if (tokens.length == 0) return null;
  //   }

  //   const unsubscribePromises: any[] = [];
  //   forumTopics.forEach((topic: string) => {
  //     unsubscribePromises.push(admin.messaging().unsubscribeFromTopic(tokens, topic));
  //   });
  //   const unsubscribeResult = await Promise.all(unsubscribePromises);

  //   const forumSubscription = await this.getSubscribedForum(uid);
  //   if (forumSubscription.length == 0) return null;

  //   const subscribePromises: any[] = [];
  //   forumSubscription.forEach((topic: string) => {
  //     subscribePromises.push(admin.messaging().subscribeToTopic(tokens, topic));
  //   });
  //   const subscribeResult = await Promise.all(subscribePromises);

  //   return {
  //     user: user,
  //     uid: uid,
  //     beforeToken: initialTokens,
  //     afterTokens: tokens,
  //     forumSubs: forumSubscription,
  //     tokenError: res.errors,
  //     subscribeResult: subscribeResult,
  //     unsubscribeResult: unsubscribeResult,
  //   };
  // }
}
