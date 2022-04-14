import * as admin from "firebase-admin";
import { config } from "./fireflutter.config";

admin.initializeApp({
  databaseURL: config.databaseURL,
  storageBucket: config.storageBucket,
});

admin.firestore().settings({ ignoreUndefinedProperties: true });

export * from "./indexes/point.functions";
export * from "./indexes/forum.functions";
export * from "./indexes/storage.functions";
export * from "./indexes/meilisearch.functions";
export * from "./indexes/messaging.functions";
export * from "./indexes/admin.functions";
export * from "./indexes/quiz.functions";
export * from "./indexes/basic.functions";
export * from "./indexes/job.functions";
