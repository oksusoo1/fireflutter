import * as functions from "firebase-functions";
import * as express from "express";
import { User } from "./classes/user";

export async function ready(
  options: {
    req: functions.https.Request;
    res: express.Response;
    auth?: boolean;
  },
  callback: (data: any) => Promise<void>
) {
  const req = options.req;
  const res = options.res;
  res.set("Access-Control-Allow-Origin", "*");

  if (req.method === "OPTIONS") {
    // Send response to OPTIONS requests
    res.set("Access-Control-Allow-Methods", "GET");
    res.set("Access-Control-Allow-Methods", "POST");
    res.set("Access-Control-Allow-Methods", "DELETE");
    res.set("Access-Control-Allow-Methods", "PUT");
    res.set("Access-Control-Allow-Headers", "Content-Type");
    res.set("Access-Control-Max-Age", "3600");
    res.status(204).send("");
  } else {
    const data = Object.assign({}, req.body, req.query);

    if (options.auth) {
      const re = User.authenticate(data);
      if (re) {
        res.status(200).send(re);
      }
    }
    callback(data).catch((e) => {
      res.status(200).send(e);
    });
  }
}
