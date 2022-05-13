/**
 * @file messaging.functions.ts
 *
 */
import * as functions from "firebase-functions";
import { Messaging } from "../classes/messaging";
import { ready } from "../ready";

export const sendMessageToAllUsers = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest(async (req, res) => {
    ready({ req, res, auth: true }, async (data) => {
      data["topic"] = Messaging.defaultTopic;
      res.status(200).send(await Messaging.sendMessageToTopic(data));
    });
  });

export const sendMessageToTopic = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest(async (req, res) => {
    ready({ req, res, auth: true }, async (data) => {
      res.status(200).send(await Messaging.sendMessageToTopic(data));
    });
  });

export const sendMessageToTokens = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest(async (req, res) => {
    ready({ req, res, auth: true }, async (data) => {
      res.status(200).send(await Messaging.sendMessageToTokens(data));
    });
  });

export const sendMessageToUsers = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest(async (req, res) => {
    ready({ req, res, auth: true }, async (data) => {
      res.status(200).send(await Messaging.sendMessageToUsers(data));
    });
  });

export const sendMessageToChatUser = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest(async (req, res) => {
    ready({ req, res, auth: true }, async (data) => {
      res.status(200).send(await Messaging.sendMessageToChatUser(data));
    });
  });

export const updateToken = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest(async (req, res) => {
    ready({ req, res, auth: true }, async (data) => {
      res.status(200).send(await Messaging.updateToken(data));
    });
  });

export const subscribeTopic = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest(async (req, res) => {
    ready({ req, res, auth: true }, async (data) => {
      res.status(200).send(await Messaging.subscribeToTopic(data));
    });
  });

export const unsubscribeTopic = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest(async (req, res) => {
    ready({ req, res, auth: true }, async (data) => {
      res.status(200).send(await Messaging.unsubscribeToTopic(data));
    });
  });

export const topicOn = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest(async (req, res) => {
    ready({ req, res, auth: true }, async (data) => {
      res.status(200).send(await Messaging.topicOn(data));
    });
  });

export const topicOff = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest(async (req, res) => {
    ready({ req, res, auth: true }, async (data) => {
      res.status(200).send(await Messaging.topicOff(data));
    });
  });

export const toggleTopic = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest(async (req, res) => {
    ready({ req, res, auth: true }, async (data) => {
      res.status(200).send(await Messaging.topicToggle(data));
    });
  });

export const enableAllNotification = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest(async (req, res) => {
    ready({ req, res, auth: true }, async (data) => {
      res.status(200).send(await Messaging.enableAllNotification(data));
    });
  });

export const disableAllNotification = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest(async (req, res) => {
    ready({ req, res, auth: true }, async (data) => {
      res.status(200).send(await Messaging.disableAllNotification(data));
    });
  });
