import * as functions from "firebase-functions";
import { Utils } from "../classes/utils";
import { ERROR_TEST } from "../defines";
import { ready, sanitizeError } from "../ready";

export const inputTest = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest((req, res) => {
      ready({ req, res, auth: false }, async (data) => {
        res.status(200).send(data);
      });
    });

export const authTest = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest((req, res) => {
      ready({ req, res, auth: true }, async (data) => {
        res.status(200).send(data);
      });
    });

export const serverTime = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest((req, res) => {
      ready({ req, res, auth: false }, async () => {
        res.status(200).send({ timestamp: Utils.getTimestamp() });
      });
    });

export const produceErrorString = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest((req, res) => {
      ready({ req, res, auth: false }, async () => {
        res.status(200).send(ERROR_TEST);
      });
    });

export const produceErrorObject = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest((req, res) => {
      ready({ req, res, auth: false }, async () => {
        res.status(200).send(sanitizeError(ERROR_TEST));
      });
    });
