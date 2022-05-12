import * as admin from "firebase-admin";
import {
  ERROR_EMPTY_TOKEN,
  ERROR_EMPTY_TOKENS,
  ERROR_EMPTY_TOPIC,
  ERROR_EMPTY_TOPIC_TYPE,
  ERROR_EMPTY_UID,
  ERROR_EMPTY_UIDS,
  ERROR_TITLE_AND_BODY_CANT_BE_BOTH_EMPTY,
} from "../defines";
import {
  ChatRequestData,
  MessagePayload,
  SendMessageBaseRequest,
  SendMessageToTokensRequest,
  SendMessageToTopicRequest,
  SendMessageToUserRequest,
  SubscriptionResponse,
  TokenDocument,
  TopicData,
} from "../interfaces/messaging.interface";
import { Ref } from "./ref";
import { Utils } from "./utils";

import axios from "axios";

import { config } from "../fireflutter.config";
import { MessagingTopicManagementResponse } from "firebase-admin/lib/messaging/messaging-api";
import { MapStringBoolean, MapStringString } from "../interfaces/common.interface";
import { Category } from "./category";
import { CategoryDocument } from "../interfaces/forum.interface";

export class Messaging {
  static defaultTopic = "defaultTopic";
  static commentNotificationField = "newCommentUnderMyPostOrComment";

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
    return await this.resubscribeAllUserTopics(data.uid);
  }

  /**
   *
   * @param data
   *  uid - user id
   *  token - device token or browser token
   *
   * @returns tokens ref
   */
  static async setToken(data: TokenDocument) {
    if (data.uid == null || data.uid == "") throw ERROR_EMPTY_UID;
    if (data.token == null || data.token == "") throw ERROR_EMPTY_TOKEN;
    await Ref.messageTokens.child(data.token).set({ uid: data.uid });
    return this.getToken(data.token);
  }

  /**
   * Returns the token record
   * @param token
   * @returns
   */
  static async getToken(token: string): Promise<null | TokenDocument> {
    const snapshot = await Ref.token(token).get();
    if (snapshot.exists()) {
      const data = snapshot.val();
      data.token = snapshot.key;
      return data;
    } else {
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
  static async subscribeToTopic(data: TopicData): Promise<SubscriptionResponse> {
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
    const res: MessagingTopicManagementResponse = await admin
      .messaging()
      .subscribeToTopic(tokens, data.topic);
    // remove invalid tokens if any
    const failureTokens: MapStringString = await this.removeInvalidTokensFromResponse(tokens, res);

    // return failuretokens tokens with failure reason and success and failure count
    return {
      topic: data.topic,
      tokens: tokens,
      failureTokens: failureTokens,
      successCount: res?.successCount ?? 0,
      failureCount: res?.failureCount ?? 0,
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
  static async unsubscribeToTopic(data: TopicData): Promise<SubscriptionResponse> {
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
    const res: MessagingTopicManagementResponse = await admin
      .messaging()
      .unsubscribeFromTopic(tokens, data.topic);
    // remove invalid tokens if any
    const failureTokens: MapStringString = await this.removeInvalidTokensFromResponse(tokens, res);

    // return failuretokens tokens with failure reason and success and failure count
    return {
      topic: data.topic,
      tokens: tokens,
      failureTokens: failureTokens,
      successCount: res?.successCount ?? 0,
      failureCount: res?.failureCount ?? 0,
    };
  }

  /**
   * Check if the data is set and not empty
   * @param data
   *  uid - user id
   *  topic - topic to subscribe
   *  type - folderName
   */
  static checkTopicData(data: TopicData) {
    if (!data.uid) throw ERROR_EMPTY_UID;
    if (!data.topic) throw ERROR_EMPTY_TOPIC;
    if (!data.type) throw ERROR_EMPTY_TOPIC_TYPE;
  }

  /**
   * Toggle the user topic true or false
   * @param data
   * @returns
   */
  static async topicToggle(data: TopicData) {
    this.checkTopicData(data);
    const topic = await this.getTopic(data);
    if (topic != null && topic[data.topic]) {
      return this.topicOff(data);
    } else {
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
  static async topicOn(data: TopicData) {
    this.checkTopicData(data);
    await Ref.userSettingTopic(data.uid)
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
  static async topicOff(data: TopicData) {
    this.checkTopicData(data);
    await Ref.userSettingTopic(data.uid)
      .child(data.type)
      .update({
        [data.topic]: false,
      });

    return this.getTopics(data.uid, data.type);
  }

  static async getTopic(data: TopicData) {
    const snapshot = await Ref.userSettingTopic(data.uid).child(data.type).child(data.topic).get();
    if (snapshot.exists()) {
      const val = snapshot.val() as boolean;
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
  static async getTopics(uid: string, type: string): Promise<MapStringBoolean | null> {
    const snapshot = await Ref.userSettingTopic(uid).child(type).get();
    if (snapshot.exists()) {
      const val = snapshot.val() as MapStringBoolean;
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
  static async removeInvalidTokens(uid: string) {
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
   * @returns array of topic as string
   */
  static async unsubscribeAllTopicOfToken(token: string) {
    // get all topics topics
    const topics = await this.getTokenTopics(token);
    if (topics.length == 0) return [];

    const promises: Promise<MessagingTopicManagementResponse>[] = [];
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
  static async getTokens(uid: string): Promise<string[]> {
    if (!uid) return [];
    const snapshot = await Ref.messageTokens.orderByChild("uid").equalTo(uid).get();
    // console.log("snapshot.exists()", snapshot.exists(), snapshot.val());
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
    if (!uids) return [];
    const promises: Promise<string[]>[] = [];
    uids.split(",").forEach((uid) => promises.push(this.getTokens(uid)));
    return (await Promise.all(promises)).flat();
  }

  // check the uids if they are subscribe to topic and also want to get notification under their post/comment
  /**
   * Get ancestors who subscribed to 'comment notification' but removing those who subscribed to the topic.
   * @param {*} uids ancestors
   * @param {*} path user setting topic path
   * @returns UIDs of ancestors.
   */
  static async getUidsWithoutSubscription(uids: string, path: string) {
    const result = await this.usersHasSubscription(uids, path);
    const re = [];
    const _uids = uids.split(",");
    // console.log("result", uids, result);
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

  /**
   * Returns an array of uid that has subscribed to the topic(of the path).
   *
   *
   * @param uids user uids
   * @param path path to user settings user-settings/{uid}/path
   *        path can be `forum/posts_qna`, `job/accountant`, or `newCommentUnderMyPostOrComment`.
   * @returns uids with user subscription with truthy value
   */
  static async getUidsWithSubscription(uids: string, path: string): Promise<string[]> {
    const result = await this.usersHasSubscription(uids, path);
    const re = [];
    const _uids = uids.split(",");
    for (const i in result) {
      // console.log(result[i]);
      // check if user subscribe to topic
      if (result[i]) {
        re.push(_uids[i]);
      }
    }
    return re;
  }

  /**
   *
   * @param uid user id
   * @param path can be main setting or with subsetting `isAdmin` or `topic/forum` or `topic/forum/posts_qna`
   * @returns
   */
  static async userSettingsField(uid: string, path: string): Promise<any> {
    const snapshot = await Ref.userSettings(uid).child(path).get();
    if (snapshot.exists() === false) return null;
    const val = snapshot.val();
    return val;
  }

  /**
   * Returns true if the user subscribed the topic.
   * @param uid uid of a user
   * @param path setting path  'forum/posts_qna'  or  'chat/user_A'
   * @returns Promise<boolean>
   */
  static async userHasSusbscription(uid: string, path: string): Promise<boolean> {
    // / Get the setting of the user base on path
    const snapshot = await Ref.userSettings(uid).child(path).get();
    if (snapshot.exists() === false) return false;
    const val = snapshot.val();
    if (!val) return false;
    return !!val;
  }

  static async usersHasSubscription(uids: string, path: string): Promise<boolean[]> {
    const _uids = uids.split(",");
    const promises: Promise<boolean>[] = [];
    _uids.forEach((uid) => promises.push(this.userHasSusbscription(uid, path)));
    return Promise.all(promises);
  }

  static async usersHasSubscriptionOff(uids: string, path: string): Promise<boolean[]> {
    const promises: Promise<boolean>[] = [];
    const _uids = uids.split(",");
    _uids.forEach((uid) => promises.push(this.userHasSusbscriptionOff(uid, path)));
    return Promise.all(promises);
  }

  /**
   * Returns true if the user turn off manually the subscription.
   * @param uid uid of a suer
   * @param path topic/folder/option
   * @returns Promise<boolean>
   */
  static async userHasSusbscriptionOff(uid: string, path: string): Promise<boolean> {
    // / Get all the topics of the user
    const snapshot = await Ref.userSettings(uid).child(path).get();
    console.log(snapshot.exists());
    if (snapshot.exists() === false) return false;
    const val = snapshot.val();

    if (!val) return false;
    // If it's undefined, then user didn't subscribed ever since.
    if (typeof val === undefined) return false;
    // If it's false, then it is disabled manually by the user.
    if (val === false) return true;
    // If it's true, then the topic is subscribed.
    return false;
  }

  /**
   * Return uids of the user didnt turn off their subscription
   * Note* user without topic info will also be included.
   * @param uids
   * @param path
   * @returns
   */
  static async removeUserHasSubscriptionOff(uids: string, path: string) {
    const _uids = uids.split(",");
    const results = await this.usersHasSubscriptionOff(uids, path);

    const re = [];
    // dont add user who has turn off subscription
    for (const i in results) {
      if (!results[i]) re.push(_uids[i]);
    }
    return re;
  }

  static topicPayload(topic: string, query: SendMessageBaseRequest): admin.messaging.TopicMessage {
    const payload = this.preMessagePayload(query);
    payload["topic"] = "/topics/" + topic;
    return payload as admin.messaging.TopicMessage;
  }

  // static checkQueryPayload(query: any): SendMessageBaseRequest {
  //   query.id = query.id ?? query.postId ?? "";
  //   query.body = query.body ?? query.content ?? "";
  //   query.senderUid = query.senderUid ?? query.uid ?? "";
  //   return query;
  // }

  static preMessagePayload(query: SendMessageBaseRequest) {
    // query = this.checkQueryPayload(query);
    if (!query.title && !query.body) throw ERROR_TITLE_AND_BODY_CANT_BE_BOTH_EMPTY;
    const res: MessagePayload = {
      data: {
        id: query.id ?? "",
        type: query.type ?? "",
        senderUid: query.senderUid ?? "",
        badge: query.badge ?? "",
      },
      notification: {
        title: query.title ?? "",
        body: query.body ?? "",
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

  static async sendMessageToTopic(query: SendMessageToTopicRequest) {
    if (!query.topic) throw ERROR_EMPTY_TOPIC;
    const payload = this.topicPayload(query.topic, query);
    try {
      const res = await admin.messaging().send(payload);
      return { messageId: res };
    } catch (e) {
      return { code: "error", message: (e as Error).message };
    }
  }

  static async sendMessageToTokens(query: SendMessageToTokensRequest) {
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
  static async sendMessageToUsers(query: SendMessageToUserRequest) {
    if (!query.uids) throw ERROR_EMPTY_UIDS;
    const payload = this.preMessagePayload(query);
    const tokens = await this.getTokensFromUids(query.uids);
    try {
      const res = await this.sendingMessageToTokens(tokens, payload);
      return res;
    } catch (e) {
      return { code: "error", message: (e as Error).message };
    }
  }

  static async sendMessageToChatUser(query: ChatRequestData) {
    const uids = (
      await this.removeUserHasSubscriptionOff(query.uids, "topic/chat/" + query.subscription)
    ).join(",");
    query.uids = uids;
    if (!query.uids) return { success: 0, error: 0 };
    return this.sendMessageToUsers(query);
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

  /**
   * Default it returns categoryGroup: `community` and set the subscription to folder `forum`
   * @param data
   * @returns
   */
  static async enableAllNotification(data: MapStringString) {
    const group = data.group ?? "community";
    const type = data.type ?? "forum";
    const cats = await Category.gets(group);
    const promises: Promise<any>[] = [];
    cats.forEach((cat: CategoryDocument) => {
      promises.push(
        Messaging.subscribeToTopic({
          uid: data.uid,
          topic: "posts_" + cat.id,
          type: type,
        })
      );
      promises.push(
        Messaging.subscribeToTopic({
          uid: data.uid,
          topic: "comments_" + cat.id,
          type: type,
        })
      );
    });

    await Promise.all(promises);
    return {
      group: group,
      type: type,
      categories: cats,
    };
  }

  /**
   * Default it returns categoryGroup: `community` and set the unsubscription to folder `forum`
   * @param data
   * @returns
   */
  static async disableAllNotification(data: MapStringString) {
    const group = data.group ?? "community";
    const type = data.type ?? "forum";
    const cats = await Category.gets(group);
    const promises: Promise<any>[] = [];
    cats.forEach((cat: CategoryDocument) => {
      promises.push(
        Messaging.unsubscribeToTopic({
          uid: data.uid,
          topic: "posts_" + cat.id,
          type: type,
        })
      );
      promises.push(
        Messaging.unsubscribeToTopic({
          uid: data.uid,
          topic: "comments_" + cat.id,
          type: type,
        })
      );
    });
    await Promise.all(promises);
    return {
      group: group,
      type: type,
      categories: cats,
    };
  }
}
