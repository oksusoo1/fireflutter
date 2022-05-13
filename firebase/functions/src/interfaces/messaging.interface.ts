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

export interface ChatRequestData extends SendMessageToUserRequest {
  subscription: string;
}

export interface SendMessageToUserRequest extends SendMessageBaseRequest {
  uids: string;
}

export interface SendMessageToTopicRequest extends SendMessageBaseRequest {
  topic: string;
}

export interface SendMessageToTokensRequest extends SendMessageBaseRequest {
  tokens: string;
}

export interface SendMessageBaseRequest {
  id?: string; /// postId
  uid?: string; /// added by 'auth' in flutter.
  title?: string;
  body?: string; /// content
  type?: string;
  senderUid?: string; /// uid
  badge?: string;
}

export interface SubscriptionResponse {
  topic: string;
  tokens: string[];
  failureTokens: MapStringString;
  successCount: number;
  failureCount: number;
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
