import * as functions from "firebase-functions";
import { Utils } from "../classes/utils";
import { ready } from "../ready";

export const inputTest = functions.region("asia-northeast3").https.onRequest((req, res) => {
  ready({ req, res, auth: false }, async (data) => {
    res.status(200).send(data);
  });
});

export const authTest = functions.region("asia-northeast3").https.onRequest((req, res) => {
  ready({ req, res, auth: true }, async (data) => {
    res.status(200).send(data);
  });
});

export const serverTime = functions.region("asia-northeast3").https.onRequest((req, res) => {
  ready({ req, res, auth: false }, async (data) => {
    res.status(200).send(Utils.getTimestamp());
  });
});
