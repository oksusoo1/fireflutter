import * as functions from "firebase-functions";
import * as express from "express";
import { User } from "./classes/user";

export function sanitizeError(e: any) {
  if (typeof e === "string" && e.startsWith("ERROR_")) {
    return { code: e };
  } else {
    return e;
  }
}

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
      const re = await User.authenticate(data);
      if (re) {
        res.status(200).send(sanitizeError(re));
        return;
      }

      // / Delete password if exists.
      if (data.password) delete data.password;
    }
    callback(data).catch((e) => {
      res.status(200).send(sanitizeError(e));
    });
  }
}
