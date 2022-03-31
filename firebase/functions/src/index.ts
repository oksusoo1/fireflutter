import * as admin from "firebase-admin";
import { config } from "./fireflutter.config";

admin.initializeApp({
  databaseURL: config.databaseURL,
  storageBucket: config.storageBucket,
});

export * from "./indexes/point.functions";
export * from "./indexes/job.functions";
export * from "./indexes/storage.functions";
