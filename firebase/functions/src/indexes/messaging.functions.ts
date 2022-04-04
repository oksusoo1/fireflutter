/**
 * @file messaging.functions.ts
 *
 */
import * as functions from "firebase-functions";
import { Messaging } from "../classes/messaging";
import { ready } from "../ready";

export const sendMessageToAll = functions.region("asia-northeast3").https.onRequest(async (req, res) => {
  ready({ req, res, auth: true }, async () => {
    const query = req.query;
    query["topic"] = "defaultTopic";
    res.status(200).send(await Messaging.sendMessageToTopic(query));
  });
});

export const sendMessageToTopic = functions.region("asia-northeast3").https.onRequest(async (req, res) => {
  ready({ req, res, auth: true }, async () => {
    res.status(200).send(await Messaging.sendMessageToTopic(req.query));
  });
});

export const sendMessageToTokens = functions.region("asia-northeast3").https.onRequest(async (req, res) => {
  ready({ req, res, auth: true }, async () => {
    res.status(200).send(await Messaging.sendMessageToTokens(req.query));
  });
});

export const sendMessageToUsers = functions.region("asia-northeast3").https.onRequest(async (req, res) => {
  ready({ req, res, auth: true }, async () => {
    res.status(200).send(await Messaging.sendMessageToUsers(req.query));
  });
});
