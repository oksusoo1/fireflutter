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

///
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
      res.status(200).send(await Messaging.subscribeTopic(data));
    });
  });

export const unsubscribeTopic = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest(async (req, res) => {
    ready({ req, res, auth: true }, async (data) => {
      res.status(200).send(await Messaging.unsubscribeTopic(data));
    });
  });

// export const resubscribeTopic = functions
//   .region("asia-northeast3")
//   .database.ref("/message-tokens")
//   .onUpdate(
//     (
//       change: functions.Change<functions.database.DataSnapshot>,
//       context: functions.EventContext
//     ) => {
//       // Exit when the data is deleted.
//       if (!change.after.exists()) {
//         return null;
//       }
//       return Messaging.resubscribeTopics(change.after.val() as UserDocument, context.params.uid);
//     }
//   );
