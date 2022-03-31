export interface MessagePayload {
  topic?: string;
  token?: string;
  data: {
    id?: string;
    type?: string;
    sender_uid?: string;
    badge?: number;
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
