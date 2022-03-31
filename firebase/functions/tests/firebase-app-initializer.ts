import * as admin from "firebase-admin";
import { config } from "../src/fireflutter.config";

export class FirebaseAppInitializer {
  constructor() {
    try {
      admin.initializeApp({
        credential: admin.credential.cert(config.adminSdkKey),
        databaseURL: config.databaseURL,
        storageBucket: config.storageBucket,
      });
    } catch (e) {}
  }
}
