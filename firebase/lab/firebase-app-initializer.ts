import * as admin from "firebase-admin";
import { config } from "../functions/src/fireflutter.config";

export class FirebaseAppInitializer {
  constructor() {
    try {
      admin.initializeApp({
        credential: admin.credential.cert({
          projectId: config.adminSdkKey.project_id,
          privateKey: config.adminSdkKey.private_key,
          clientEmail: config.adminSdkKey.client_email
        }),
        databaseURL: config.databaseURL,
        storageBucket: config.storageBucket,
      });

      admin.firestore().settings({ ignoreUndefinedProperties: true });
    } catch (e) {
      console.error("initialization failed; ", e);
    }
  }
}
