import * as functions from "firebase-functions";
import * as express from "express";

export async function cors(
  req: functions.https.Request,
  res: express.Response,
  callback: () => Promise<void>
) {
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
    callback().catch((e) => {
      res.status(200).send(e);
    });
  }
}
