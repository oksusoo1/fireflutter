/**
 * @file messaging.functions.ts
 *
 */
import * as functions from "firebase-functions";
import { Messaging } from "../classes/messaging";
import { ready } from "../ready";

export const sendMessageToAll = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest(async (req, res) => {
      ready({ req, res, auth: true }, async (data) => {
        data["topic"] = "defaultTopic";
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
