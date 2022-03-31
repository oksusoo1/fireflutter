import * as admin from "firebase-admin";
import * as wonderfulKorea from "./wonderful-korea.config";

admin.initializeApp({
  databaseURL: wonderfulKorea.config.databaseURL,
});

export * from "./indexes/point.functions";
export * from "./indexes/job.functions";
