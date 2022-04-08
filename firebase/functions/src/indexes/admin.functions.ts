/**
 * @file messaging.functions.ts
 *
 */
import * as functions from "firebase-functions";
import { User } from "../classes/user";

export const enableUser = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    return await User.enableUser(data, context);
  });

export const disableUser = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    return await User.disableUser(data, context);
  });

export const adminUserSearch = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    return await User.adminUserSearch(data, context);
  });
