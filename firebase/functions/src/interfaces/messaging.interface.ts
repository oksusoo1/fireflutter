import { MapStringString } from "./common.interface";

export interface TokenDocument {
  uid: string;
  token: string;
}

export interface TopicData {
  uid: string;
  topic: string;
  type: string;
}

export interface SubscriptionResponse {
  topic: string;
  tokens: string[];
  successCount: number;
  failureCount: number;
  failureToken: MapStringString;
}

export interface MessagePayload {
  topic?: string;
  token?: string;
  data: {
    id?: string;
    type?: string;
    senderUid?: string;
    badge?: string;
  };
  notification: {
    title: string;
    body: string;
  };
  android: {
    notification: {
      channelId?: string;
      clickAction?: string;
      sound?: string;
    };
  };
  apns: {
    payload: {
      aps: {
        sound: string;
        badge?: number;
      };
    };
  };
}

export interface OnCommentCreateResponse {
  topicResponse: string;
  tokenResponse: {
    success: number;
    error: number;
  };
}
