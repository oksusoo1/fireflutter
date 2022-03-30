import * as admin from "firebase-admin";
import * as wonderfulKorea from "../../wonderful-korea.config";

export class FirebaseAppInitializer {
  constructor() {
    try {
      admin.initializeApp({
        credential: admin.credential.cert(wonderfulKorea.config.adminSdkKey),
        databaseURL: wonderfulKorea.config.databaseURL,
      });
    } catch (e) {}
  }
}
