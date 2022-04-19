/**
 * @file job.functions.ts
 *
 * HTTP events for forum functions.
 * (Calling functions via HTTP request, HTTP trigger)
 *
 * CORS
 *  By design, http calls are allowed only from same domain.
 *  If client is from different domain, you need cors.
 *
 * Preflight
 *  By design, only allowed HTTP methods could be made.
 *
 *
 *
 */
import * as functions from "firebase-functions";
import { Job } from "../classes/job";
import { ready } from "../ready";

// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript

export const jobCreate = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest((req, res) => {
      ready({ req, res, auth: true }, async (data) => {
        res.status(200).send(await Job.create(data));
      });
    });

export const jobUpdate = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest((req, res) => {
      ready({ req, res, auth: true }, async (data) => {
        res.status(200).send(await Job.update(data));
      });
    });

export const jobUpdateProfile = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest((req, res) => {
      ready({ req, res, auth: true }, async (data) => {
        res.status(200).send(await Job.updateProfile(data));
      });
    });

export const jobGetProfile = functions
    .region("us-central1", "asia-northeast3")
    .https.onRequest((req, res) => {
      ready({ req, res, auth: false }, async (data) => {
        res.status(200).send(await Job.getProfile(data.uid));
      });
    });
