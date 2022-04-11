/**
 * @file messaging.functions.ts
 *
 */
import * as functions from "firebase-functions";
import { User } from "../classes/user";
import { sanitizeError } from "../ready";

export const enableUser = functions
    .region("us-central1", "asia-northeast3")
    .https.onCall(async (data, context) => {
      return sanitizeError(await User.enableUser(data, context));
    });

export const disableUser = functions
    .region("us-central1", "asia-northeast3")
    .https.onCall(async (data, context) => {
      return sanitizeError(await User.disableUser(data, context));
    });

export const adminUserSearch = functions
    .region("us-central1", "asia-northeast3")
    .https.onCall(async (data, context) => {
      return sanitizeError(await User.adminUserSearch(data, context));
    });
