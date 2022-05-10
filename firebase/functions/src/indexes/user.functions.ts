import * as functions from "firebase-functions";
import { User } from "../classes/user";
import { ready } from "../ready";

export const postList = functions
  .region("us-central1", "asia-northeast3")
  .https.onRequest((req, res) => {
    ready({ req, res }, async (data) => {
      res.status(200).send(await User.getSignInToken(data));
    });
  });
